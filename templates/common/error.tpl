<!-- Content Header (Page header) -->
<section class="content-header">
    <h1>
        {$code} Error Page
    </h1>
</section>

<!-- Main content -->
<section class="content">

    <div class="error-page">
        <h2 class="headline text-info">{$code}</h2>
        <div class="error-content">
            <h3><i class="fa fa-warning text-yellow"></i>{$title}</h3>
            <p>

                {$message}
                Meanwhile, you may <a class="dynamic_load" href="{$BASE_URL}catalog">return to catalog</a>.
            </p>
        </div><!-- /.error-content -->
    </div><!-- /.error-page -->

</section><!-- /.content -->

<script type="text/javascript">
    $.ready(function() {
        $('#helpBtn').off().hide();
    });
</script>