<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <title>Slow request</title>
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
    <?php wp_body_open(); ?>
    <main style="padding: 2rem;">
        <p><a href="<?php echo esc_url(home_url('/')); ?>">Back to the homepage</a></p>
        <p>Well, that took forever!</p>
    </main>
    <?php wp_footer(); ?>
</body>
</html>
