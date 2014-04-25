<ul id="catalog-nav-bar" class="nav nav-tabs nav-justified pull-left">
    <li {if $active == "whatsHot"}class="active"{/if}>
        <a class="dynamic_load" href="{$BASE_URL}hot/{$skip}">What's Hot</a>
    </li>
    <li {if $active == "topRated"}class="active"{/if}>
        <a class="dynamic_load" href="{$BASE_URL}top/{$skip}">Top Rated</a>
    </li>
    <li {if $active == "new"}class="active"{/if}>
        <a class="dynamic_load" href="{$BASE_URL}new/{$skip}">New</a>
    </li>
    <li {if $active == "random"}class="active"{/if}>
        <a class="dynamic_load" href="{$BASE_URL}rand/{$skip}">Random</a>
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
        {if $active == "whatsHot"}
        <li><a href="{$BASE_URL}hot/{$prevSkip}">Previous</a></li>
        <li><a href="{$BASE_URL}hot/{$nextSkip}">Next</a></li>
        {elseif $active == "topRated"}
        <li><a href="{$BASE_URL}top/{$prevSkip}">Previous</a></li>
        <li><a href="{$BASE_URL}top/{$nextSkip}">Next</a></li>
        {elseif $active == "new"}
        <li><a href="{$BASE_URL}new/{$prevSkip}">Previous</a></li>
        <li><a href="{$BASE_URL}new/{$nextSkip}">Next</a></li>
        {/if}
    </ul>
</section>