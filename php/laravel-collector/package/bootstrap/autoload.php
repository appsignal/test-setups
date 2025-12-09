<?php

use AppSignal\LaravelAppSignal\AppSignal;

// Skip for CLI unless it's artisan
if (PHP_SAPI === 'cli' && !isset($_ENV['LARAVEL_ARTISAN'])) {
	return;
}

AppSignal::initialize();
