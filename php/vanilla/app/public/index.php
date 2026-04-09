<?php

require_once __DIR__ . '/../vendor/autoload.php';

use App\Router;

$method = $_SERVER['REQUEST_METHOD'];
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

Router::handle($method, $uri);
