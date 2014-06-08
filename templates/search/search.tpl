<section class="content">
    <div class="row">
        <ul class="nav nav-tabs nav-justified tabs-bar">
            <li class="active">
                <a href="#" data-filter="" class="tab-link">All</a>
            </li>
            <li>
                <a href="#" data-filter="model" class="tab-link">Models</a>
            </li>
            <li>
                <a href="#" data-filter="user" class="tab-link">People</a>
            </li>
            <li>
                <a href="#" data-filter="group" class="tab-link">Groups</a>
            </li>
        </ul>

        <div id="search_results">

            <div class="container">
                <section class="col-xs-12 col-sm-6 col-md-12">
                    {foreach $results as $result }
                        {if $result.type === 'model'}
                            {include file="search/modelSearchComp.tpl" model=$result}
                        {elseif $result.type === 'member'}
                            {include file="search/memberSearchComp.tpl" member=$result}
                        {elseif $result.type === 'group'}
                            {include file="search/groupSearchComp.tpl" group=$result}
                        {/if}
                    {/foreach}

                </section>
            </div>
        </div>
    </div>
</section>

<script src="{$BASE_URL}js/pages/search.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/plugins/bootstrap3-dialog/bootstrap-dialog.min.js" type="text/javascript"></script>
<script type="text/javascript">
    function askFriend(btn) {
        var thisButton = $(btn);
        var memId = thisButton.attr('name');
        thisButton.addClass('disabled');
        thisButton.prepend('<span class="bootstrap-dialog-button-icon glyphicon glyphicon-asterisk icon-spin"></span>');
        $.ajax({
            url: '{$BASE_URL}members/friend/' + memId,
            type: 'POST',
            success: function (a) {
                BootstrapDialog.alert({
                    title: 'Success!',
                    message: 'Sent this member a friend request!'
                });
                thisButton.parent().remove();
            },
            error: function (a, b, c) {
                BootstrapDialog.alert({
                    title: 'Oops!',
                    message: 'Could not process your request at this time. :(\nError: ' + c});
                thisButton.find('span').remove();
                thisButton.removeClass('disabled');
            }
        });
    }
</script>
<script>
    $(document).ready(function() {

    });
</script>