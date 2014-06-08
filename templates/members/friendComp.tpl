<article class="search-result row user">
    <div class="col-xs-12 col-sm-12 col-md-3">
        <a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$member.id}" title="Lorem ipsum" class="thumbnail">
            <img src="{$GRAVATAR_URL}{$member.hash}?s=140&amp;d=identicon" alt="{$member.name}" />
        </a>
    </div>
    <div class="col-xs-12 col-sm-12 col-md-2">
        <ul class="meta-search">
            {*<li>
                <i class="glyphicon glyphicon-time"></i>
                <span>4:28 pm</span>
            </li>*}
            <li>
                <i class="glyphicon glyphicon-tags"></i>
                <span>Member</span>
            </li>
            {if !$member.isFriend}
                <li>
                    <a href="#" class="btn btn-primary" role="button">Add Friend</a>
                </li>
            {/if}
        </ul>
    </div>
    <div class="col-xs-12 col-sm-12 col-md-7 excerpet">
        <h3>
            <a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$member.id}" title="">{$member.name}</a>
        </h3>
        <p class="about">{$member.about}</p>
    </div>
    <span class="clearfix borda"></span>
</article>