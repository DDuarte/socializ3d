<ul id="catalog-nav-bar" class="nav nav-tabs nav-justified pull-left">
    <li {if $active == "whatsHot"}class="active"{/if}>
        <a class="dynamic_load" href="{$BASE_URL}hot">What's Hot</a>
    </li>
    <li {if $active == "topRated"}class="active"{/if}>
        <a class="dynamic_load" href="{$BASE_URL}top">Top Rated</a>
    </li>
    <li {if $active == "new"}class="active"{/if}>
        <a class="dynamic_load" href="{$BASE_URL}new">New</a>
    </li>
    <li {if $active == "random"}class="active"{/if}>
        <a class="dynamic_load" href="{$BASE_URL}rand">Random</a>
    </li>
</ul>
<section class="content">
    <div class="row catalogue" style="margin-top:30px">
        {foreach $models as $model}
            <div class="col-xs-12 col-sm-4 col-md-4 col-lg-3">
                {include file="models/thumbnail.tpl" model=$model}
            </div>
        {/foreach}
    </div>

    <ul id="model-pager" class="pager">
        <li><a href="#">Previous</a></li>
        <li><a href="#">Next</a></li>
    </ul>
</section>