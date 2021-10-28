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
	print(source_file)
	var newTargetSplitBase = source_file.get_basename()
	print(newTargetSplitBase)
	var my_file = File.new()
	my_file.open(source_file, File.READ)
	var file_size = my_file.get_len()
	var mem_temp = my_file.get_buffer(file_size)
	my_file.close()

	var img = Image.new()
	img.load_png_from_buffer(mem_temp)

	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)

	
	var hSplit = texture.get_width() / options.Columns
	var vSplit = texture.get_height() / options.Rows

	print_debug(options)
	for i in range(0,options.Columns):
		for j in range(0,options.Rows):
			var splitObjName = "%s.x%s_y%s.%s" % [newTargetSplitBase, str(i), str(j), get_save_extension()]
			var splitObj = AtlasTexture.new()
			splitObj.atlas = texture
			splitObj.region = Rect2(i*hSplit,j*vSplit,hSplit,vSplit)
			#print_debug(splitObjName)
			var err = ResourceSaver.save(splitObjName, splitObj)
			if err != OK:
				print_debug(err,splitObjName)
				return err
			r_gen_files.push_back(splitObjName)
	var atlasName = "%s.%s" % [save_path, get_save_extension()]
	return ResourceSaver.save(atlasName, texture)
