TEMPLATE_STATUS_SUCCESS = 0
TEMPLATE_STATUS_NOT_A_TEMPLATE = 1
TEMPLATE_STATUS_DUP_TAGS = 2

RUNNER_CONFIG_KEY_SCRIPT_FILE = 'script file'.freeze
RUNNER_CONFIG_KEY_OUTPUT_FOLDER = 'output folder'.freeze
RUNNER_CONFIG_KEY_OUTPUT_BASE_NAME = 'output file base name'.freeze
RUNNER_CONFIG_KEY_SOURCE_FILE = 'source file'.freeze

RUNNER_TAGS_CONFIG_FILE_NAME = 'config_extract_tags.jsn'.freeze
RUNNER_IMAGES_CONFIG_FILE_NAME = 'config_extract_images.jsn'.freeze
RUNNER_POST_PROCESS_CONFIG_FILE_NAME = 'config_post_process.jsn'.freeze

DESIGN_TEMPLATE_STATS_KEY_VALID = 'valid'.freeze
DESIGN_TEMPLATE_STATS_KEY_MESSAGE = 'message'.freeze
DESIGN_TEMPLATE_STATS_KEY_STATUS = 'status'.freeze

PROMPTS_KEY_TAG_SETTINGS = 'tag_settings'.freeze
PROMPTS_KEY_IMAGE_SETTINGS = 'image_settings'.freeze
PROMPTS_KEY_PROMPT = 'prompt'.freeze
PROMPTS_KEY_MAX_L = 'max_length'.freeze
PROMPTS_KEY_MIN_L = 'min_length'.freeze
PROMPTS_KEY_PICK_COLOR = 'pick_color'.freeze
PROMPTS_KEY_USE_PALETTE = 'use_palette'.freeze
PROMPTS_KEY_PALETTE_ID = 'palette_id'.freeze
PROMPTS_KEY_REPLACE_IMG = 'replace_image'.freeze
PROMPTS_KEY_ORIGINAL_IMAGE = 'original_image'.freeze
PROMPTS_KEY_ORIGINAL_HEIGHT = 'original_height'.freeze
PROMPTS_KEY_ORIGINAL_WIDTH = 'original_width'.freeze

PROMPTS_VALUE_REPLACE_IMG_TRUE = 'checked'.freeze
PROMPTS_VALUE_REPLACE_IMG_FALSE = ''.freeze
PROMPTS_VALUE_PICK_COLOR_TRUE = 'checked'.freeze
PROMPTS_VALUE_PICK_COLOR_FALSE = ''.freeze
PROMPTS_VALUE_USE_PALETTE_TRUE = 'checked'.freeze
PROMPTS_VALUE_USE_PALETTE_FALSE = ''.freeze

# Code in bin/illustrator_processing/*.jsx uses these key values also, so
# any changes must be reflected there.
VERSION_VALUES_KEY_IMAGE_SETTINGS = 'image_settings'.freeze
VERSION_VALUES_KEY_TAG_SETTINGS = 'tag_settings'.freeze

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

# Code in bin/illustrator_processing/searchAndReplaceImages.jsx uses
# these key values also, so any changes must be reflected there.
IMAGE_TYPE_COLLAGE = 'Collage'.freeze
IMAGE_TYPE_REPLACEMENT_IMAGE = 'ReplacementImage'.freeze
