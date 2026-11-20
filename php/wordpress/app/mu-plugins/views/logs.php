<!DOCTYPE html>
<html <?php language_attributes(); ?>>

<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <title>Logs</title>
    <?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
    <?php wp_body_open(); ?>
    <main style="padding: 2rem;">
        <p><a href="<?php echo esc_url(home_url('/')); ?>">Back to the homepage</a></p>
        <p>Sent a log from WordPress!</p>
    </main>
    <?php wp_footer(); ?>
</body>

</html>
