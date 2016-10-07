CACHE_KEY_VERSIONS = 'ver_cache'.freeze
CACHE_KEY_DESIGN_TEMPLATES = 'dt_cache'.freeze
CACHE_KEY_USERS = 'u_cache'.freeze
CACHE_KEY_PALETTES = 'pal_cache'.freeze
CACHE_KEY_MANAGED_ASSETS = 'ma_cache'.freeze

TEMPLATE_STATUS_SUCCESS = 0
TEMPLATE_STATUS_NOT_A_TEMPLATE = 1
TEMPLATE_STATUS_DUP_TAGS = 2

RUNNER_CONFIG_KEY_SCRIPT_FILE = 'script file'.freeze
RUNNER_CONFIG_KEY_OUTPUT_FOLDER = 'output folder'.freeze
RUNNER_CONFIG_KEY_OUTPUT_BASE_NAME = 'output file base name'.freeze
RUNNER_CONFIG_KEY_SOURCE_FILE = 'source file'.freeze

RUNNER_TAGS_CONFIG_FILE_NAME = 'config_extract_tags.jsn'.freeze
RUNNER_IMAGES_CONFIG_FILE_NAME = 'config_extract_images.jsn'.freeze
RUNNER_COLORS_CONFIG_FILE_NAME = 'config_extract_colors.jsn'.freeze
RUNNER_POST_PROCESS_CONFIG_FILE_NAME = 'config_post_process.jsn'.freeze

DESIGN_TEMPLATE_STATS_KEY_VALID = 'valid'.freeze
DESIGN_TEMPLATE_STATS_KEY_MESSAGE = 'message'.freeze
DESIGN_TEMPLATE_STATS_KEY_STATUS = 'status'.freeze

ASSET_PREFS_KEY_ORDER = 'ap_order'.freeze

PROMPTS_KEY_TAG_SETTINGS = 'tag_settings'.freeze
PROMPTS_KEY_IMAGE_SETTINGS = 'image_settings'.freeze
PROMPTS_KEY_COLOR_SETTINGS = 'color_settings'.freeze
PROMPTS_KEY_TRANS_BUTT_SETTINGS = 'trans_butt_settings'.freeze

PROMPTS_KEY_PROMPT = 'prompt'.freeze
PROMPTS_KEY_MAX_L = 'max_length'.freeze
PROMPTS_KEY_MIN_L = 'min_length'.freeze
PROMPTS_KEY_PICK_COLOR = 'pick_color'.freeze
PROMPTS_KEY_USE_PALETTE = 'use_palette'.freeze
PROMPTS_KEY_PALETTE_ID = 'palette_id'.freeze
PROMPTS_KEY_REPLACE_IMG = 'replace_image'.freeze
PROMPTS_KEY_FIT_IMG = 'fit_image'.freeze
PROMPTS_KEY_ORIGINAL_IMAGE = 'original_image'.freeze
PROMPTS_KEY_ORIGINAL_HEIGHT = 'original_height'.freeze
PROMPTS_KEY_ORIGINAL_WIDTH = 'original_width'.freeze
PROMPTS_KEY_TRANS_BUTT_LEFT_IMAGE_NAME = 'left_image_name'.freeze
PROMPTS_KEY_TRANS_BUTT_RIGHT_IMAGE_NAME = 'right_image_name'.freeze
PROMPTS_KEY_TRANS_BUTT_SET_COLOR = 'tb_set_color'.freeze
PROMPTS_KEY_REPLACE_COLOR = 'replace_color'.freeze
PROMPTS_KEY_REPLACE_COLOR_ORIG_COLOR_HEX = 'rep_co_orig_co_hex'.freeze
PROMPTS_KEY_REPLACE_COLOR_ORIG_COLOR_C = 'rep_co_orig_co_c'.freeze
PROMPTS_KEY_REPLACE_COLOR_ORIG_COLOR_M = 'rep_co_orig_co_m'.freeze
PROMPTS_KEY_REPLACE_COLOR_ORIG_COLOR_Y = 'rep_co_orig_co_y'.freeze
PROMPTS_KEY_REPLACE_COLOR_ORIG_COLOR_K = 'rep_co_orig_co_k'.freeze
PROMPTS_KEY_REPLACE_COLOR_ORIG_COLOR_NAME = 'rep_co_orig_co_name'.freeze



PROMPTS_VALUE_TRUE = 'checked'.freeze
PROMPTS_VALUE_FALSE = ''.freeze

# todo - get rid of these?
PROMPTS_VALUE_REPLACE_IMG_TRUE = 'checked'.freeze
PROMPTS_VALUE_REPLACE_IMG_FALSE = ''.freeze
PROMPTS_VALUE_PICK_COLOR_TRUE = 'checked'.freeze
PROMPTS_VALUE_PICK_COLOR_FALSE = ''.freeze
PROMPTS_VALUE_USE_PALETTE_TRUE = 'checked'.freeze
PROMPTS_VALUE_USE_PALETTE_FALSE = ''.freeze
PROMPTS_VALUE_FIT_IMG_TRUE = 'checked'.freeze
PROMPTS_VALUE_FIT_IMG_FALSE = ''.freeze

# Code in bin/illustrator_processing/*.jsx uses these key values also, so
# any changes must be reflected there.
VERSION_VALUES_KEY_IMAGE_SETTINGS = 'image_settings'.freeze
VERSION_VALUES_KEY_TAG_SETTINGS = 'tag_settings'.freeze
VERSION_VALUES_KEY_TRANS_BUTT_SETTINGS = 'trans_butt_settings'.freeze
VERSION_VALUES_KEY_COLOR_SETTINGS = 'color_settings'.freeze

VERSION_VALUES_KEY_MOD_COLOR_C = 'new_c'.freeze
VERSION_VALUES_KEY_MOD_COLOR_M = 'new_m'.freeze
VERSION_VALUES_KEY_MOD_COLOR_Y = 'new_y'.freeze
VERSION_VALUES_KEY_MOD_COLOR_K = 'new_k'.freeze
VERSION_VALUES_KEY_MOD_COLOR_HEX = 'new_hex'.freeze

VERSION_VALUES_KEY_MOD_COLOR_ORIGINAL_C = 'orig_c'.freeze
VERSION_VALUES_KEY_MOD_COLOR_ORIGINAL_M = 'orig_m'.freeze
VERSION_VALUES_KEY_MOD_COLOR_ORIGINAL_Y = 'orig_y'.freeze
VERSION_VALUES_KEY_MOD_COLOR_ORIGINAL_K = 'orig_k'.freeze
VERSION_VALUES_KEY_MOD_COLOR_ORIGINAL_HEX = 'orig_hex'.freeze


VERSION_VALUES_KEY_TB_TEXT = 'tb_text'.freeze
VERSION_VALUES_KEY_TB_COLOR = 'tb_color'.freeze
VERSION_VALUES_KEY_TB_HW_RATIO = 'tb_hw_ratio'.freeze
VERSION_VALUES_KEY_TB_V_ALIGN = 'tb_v_align'.freeze
VERSION_VALUES_KEY_TB_FONT = 'tb_font'.freeze


# Hash keys for object describing a replacement tag in Version.values
#
# Code in bin/illustrator_processing/searchAndReplace.jsx uses these
# key values also, so any changes must be reflected there.
VERSION_VALUES_KEY_REPLACEMENT_TEXT = 'replacement_text'.freeze
VERSION_VALUES_KEY_TEXT_COLOR = 'text_color'.freeze

# Hash keys for object describing an image in Version.values
#
# Code in bin/illustrator_processing/searchAndReplaceImages.jsx uses these
# key values also, so any changes must be reflected there.
VERSION_VALUES_KEY_RI_ID = 'replacement_image_id'.freeze
VERSION_VALUES_KEY_COLLAGE_ID = 'collage_id'.freeze
VERSION_VALUES_KEY_PATH = 'path'.freeze
VERSION_VALUES_KEY_TYPE = 'type'.freeze

VESION_VALUES_KEY_COLOR_ID = 'color_id'.freeze


# Code in bin/illustrator_processing/searchAndReplaceImages.jsx uses
# these key values also, so any changes must be reflected there.
IMAGE_TYPE_COLLAGE = 'Collage'.freeze
IMAGE_TYPE_REPLACEMENT_IMAGE = 'ReplacementImage'.freeze

# This is the name of the subfolder into which images are extracted.
ZIP_FILE_EXTRACTED_SUBFOLDER_NAME = 'extracted'.freeze
