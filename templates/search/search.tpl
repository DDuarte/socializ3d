<link href="{$BASE_URL}css/search.css" rel="stylesheet" type="text/css" />
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
                            {include file="search/model.tpl" model=$result.value}
                        {elseif $result.type === 'member'}
                            {include file="search/member.tpl" member=$result.value}
                        {elseif $result.type === 'group'}
                            {include file="search/group.tpl" group=$result.value}
                        {/if}
                    {/foreach}

                </section>
            </div>
        </div>
    </div>
</section>

<script src="{$BASE_URL}js/pages/search.js" type="text/javascript"></script>
<script>
    $(document).ready(function() {

    });
</script>