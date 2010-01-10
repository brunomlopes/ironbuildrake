require 'logger'

$logger = Logger.new(STDOUT)
$logger.datetime_format = "%H:%M:%S"
$logger.level = Logger::DEBUG
