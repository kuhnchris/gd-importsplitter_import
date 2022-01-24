# import_plugin.gd
tool
extends EditorImportPlugin


enum Presets { DEFAULT }


func get_preset_count():
	return Presets.size()

func get_preset_name(preset):
	match preset:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

func get_import_options(preset):
	match preset:
		Presets.DEFAULT:
			return [{
					   "name": "Columns",
					   "default_value": 5
					},
					{
					   "name": "Rows",
					   "default_value": 1
					}
					]
		_:
			return []

func get_option_visibility(_option, _options):
	return true

func get_importer_name():
	return "kuhnchris.multiteximp"

func get_visible_name():
	return "Split into AtlasTextures"

func get_recognized_extensions():
	return ["png"]

func get_save_extension():
	return "tres"

func get_resource_type():
	return "AtlasTexture"

func import(source_file, save_path, options, _r_platform_variants, r_gen_files):
	var newTargetSplitBase = source_file.get_basename()

	var srcTexture: ImageTexture = load(source_file) as ImageTexture
	if srcTexture == null:
		print("could not open source file: ",source_file)
		return false

	var hSplit = srcTexture.get_width() / options.Columns
	var vSplit = srcTexture.get_height() / options.Rows

	print_debug(source_file," - importing options: ",options)

	for i in range(0,options.Columns):
		for j in range(0,options.Rows):
			var splitObjName = "%s.x%s_y%s.%s" % [newTargetSplitBase, str(i), str(j), get_save_extension()]
			var splitObj = AtlasTexture.new()
			splitObj.atlas = srcTexture
			splitObj.region = Rect2(i*hSplit,j*vSplit,hSplit,vSplit)
			#print_debug()
			var pData = splitObj.get_data().data.data
			var buff = -1
			var allTheSame = true
			for ii in pData.size():
				if buff == -1:
					buff = pData[ii]
				else:
					if buff != pData[ii]:
						allTheSame = false
			if !allTheSame:
				var err = ResourceSaver.save(splitObjName, splitObj)
				if err != OK:
					print_debug(err,splitObjName)
					return err
				r_gen_files.push_back(splitObjName)
			else:
				print("skipping ",splitObjName," due to all the same color.")
				var existingFile = Directory.new()
				if existingFile.file_exists(splitObjName):
					print("remove existing file...")
					var err = existingFile.remove(splitObjName)

	var atlasName = "%s.%s" % [save_path, get_save_extension()]
	return ResourceSaver.save(atlasName, srcTexture)
