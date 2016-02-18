require "pathname"

$LOAD_PATH.unshift(Pathname(__FILE__).dirname.parent.join(".."))

require "flashcards"
require_relative "../../shared/integration_spec"
