TEMPLATE_STATUS_SUCCESS = 0
TEMPLATE_STATUS_NOT_A_TEMPLATE = 1
TEMPLATE_STATUS_DUP_TAGS = 2

RUNNER_CONFIG_KEY_SCRIPT_FILE = 'xx_script file'.freeze
RUNNER_CONFIG_KEY_OUTPUT_FOLDER = 'xx_output folder'.freeze
RUNNER_CONFIG_KEY_OUTPUT_BASE_NAME = 'xx_output file base name'.freeze
RUNNER_CONFIG_KEY_SOURCE_FILE = 'xx_source file'.freeze

RUNNER_TAGS_CONFIG_FILE_NAME = 'xx_config_extract_tags.jsn'.freeze
RUNNER_IMAGES_CONFIG_FILE_NAME = 'xx_config_extract_images.jsn'.freeze

DESIGN_TEMPLATE_STATS_KEY_VALID = 'valid'.freeze
DESIGN_TEMPLATE_STATS_KEY_MESSAGE = 'message'.freeze
DESIGN_TEMPLATE_STATS_KEY_STATUS = 'status'.freeze

PROMPTS_KEY_TAG_SETTINGS = 'xx_tag_settings'.freeze
PROMPTS_KEY_IMAGE_SETTINGS = 'xx_image_settings'.freeze

PROMPTS_KEY_PROMPT = 'xx_prompt'.freeze
PROMPTS_KEY_MAX_L = 'xx_max_length'.freeze
PROMPTS_KEY_MIN_L = 'xx_min_length'.freeze
PROMPTS_KEY_PICK_COLOR = 'xx_pick_color'.freeze
PROMPTS_KEY_USE_PALETTE = 'xx_use_palette'.freeze
PROMPTS_KEY_PALETTE_ID = 'xx_palette_id'.freeze
PROMPTS_KEY_REPLACE_IMG = 'xx_replace_image'.freeze

# Code in bin/illustrator_processing/*.jsx uses these key values also, so
# any changes must be reflected there.
VERSION_VALUES_KEY_IMAGE_SETTINGS = 'image_settings'.freeze
VERSION_VALUES_KEY_TAG_SETTINGS = 'tag_settings'.freeze

# Code in bin/illustrator_processing/searchAndReplaceImages.jsx uses
# these key values also, so any changes must be reflected there.
IMAGE_TYPE_COLLAGE = 'Collage'.freeze
IMAGE_TYPE_REPLACEMENT_IMAGE = 'ReplacementImage'.freeze

# Hash keys for object describing an image in Version.values
#
# Code in bin/illustrator_processing/searchAndReplaceImages.jsx uses these
# key values also, so any changes must be reflected there.
IMAGE_SETTINGS_KEY_RI_ID = 'replacement_image_id'.freeze
IMAGE_SETTINGS_KEY_COLLAGE_ID = 'collage_id'.freeze
IMAGE_SETTINGS_KEY_PATH = 'path'.freeze
IMAGE_SETTINGS_KEY_TYPE = 'type'.freeze
