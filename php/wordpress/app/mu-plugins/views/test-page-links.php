<nav style="padding: 1rem 2rem;">
    <strong>Test pages:</strong>
    <?php foreach (TEST_PAGES as $pageName => $linkLabel) : ?>
        <a href="<?php echo esc_url(home_url("/$pageName")); ?>" style="margin-left: 1rem;"><?php echo esc_html($linkLabel); ?></a>
    <?php endforeach; ?>
</nav>
