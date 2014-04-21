<article class="search-result row user">
    <div class="col-xs-12 col-sm-12 col-md-3">
        <a href="#" title="Lorem ipsum" class="thumbnail">
            <img src="{$GRAVATAR_URL}{$member.hash}?s=140" alt="{$member.name}" />
        </a>
    </div>
    <div class="col-xs-12 col-sm-12 col-md-2">
        <ul class="meta-search">
            <li>
                <i class="glyphicon glyphicon-time"></i>
                <span>4:28 pm</span>
            </li>
            <li>
                <i class="glyphicon glyphicon-tags"></i>
                <span>Member</span>
            </li>
            <li>
                <a href="#" class="btn btn-primary" role="button">Add Friend</a>
            </li>
        </ul>
    </div>
    <div class="col-xs-12 col-sm-12 col-md-7 excerpet">
        <h3>
            <a href="{$BASE_URL}users/user.php?id={$member.id}" title="">{$member.name}</a>
        </h3>
        <p class="about">{$member.about}</p>
    </div>
    <span class="clearfix borda"></span>
</article>