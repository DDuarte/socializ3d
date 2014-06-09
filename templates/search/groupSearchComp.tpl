<article class="search-result row group">
    <div class="col-xs-12 col-sm-12 col-md-3">
        <a class="dynamic_load thumbnail" href="{$BASE_URL}{$GROUPS}/{$group.id}" title="{$group.name}">
            <img style="width:197px; height:197px;" src="{$group.avatarimg}" alt="Group avatar image"/>
        </a>
    </div>
    <div class="col-xs-12 col-sm-12 col-md-2">
        <ul class="meta-search">
            <li>
                <i class="glyphicon glyphicon-tags"> </i>
                <span>Group</span>
            </li>
        </ul>
    </div>
    <div class="col-xs-12 col-sm-12 col-md-7">
        <h3>
            <a class="dynamic_load" href="{$BASE_URL}{$GROUPS}/{$group.id}">{$group.name}</a>
        </h3>

        <p class="about">{$group.about}</p>
    </div>
    <span class="clearfix borda"></span>
</article>