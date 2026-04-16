<?php

return [
    'name' => env('APPSIGNAL_APP_NAME', env('APP_NAME', 'App')),
    'environment' => env('APPSIGNAL_APP_ENV', env('APP_ENV', 'production')),
    'push_api_key' => env('APPSIGNAL_PUSH_API_KEY'),
    'collector_endpoint' => env('APPSIGNAL_COLLECTOR_ENDPOINT'),
    'disable_patches' => [],
];
