<article class="search-result row group">
    <div class="col-xs-12 col-sm-12 col-md-3">
        <a class="dynamic_load" href="{$BASE_URL}{$GROUPS}/{$group.id}" title="Lorem ipsum" class="thumbnail">
            <img src="http://placehold.it/250x140" alt="Lorem ipsum"/> {* PUT {$group.coverimg} here *}
        </a>
    </div>
    <div class="col-xs-12 col-sm-12 col-md-2">
        <ul class="meta-search">
            <li>
                <i class="glyphicon glyphicon-tags"></i>
                <span>Group</span>
            </li>
            {if $group.memberInGroup}
            <li>
                <a href="#" class="btn btn-primary" role="button">Leave Group</a>
            </li>
            {/if}
        </ul>
    </div>
    <div class="col-xs-12 col-sm-12 col-md-7">
        <h3>
            <a class="dynamic_load" href="{$BASE_URL}{$GROUPS}/{$group.id}" title="">{$group.name}</a>
        </h3>

        <p class="about">{$group.about}</p>
    </div>
    <span class="clearfix borda"></span>
</article>