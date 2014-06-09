<article class="search-result row model">
    <div class="col-xs-12 col-sm-12 col-md-3">
        <a class="dynamic_load thumbnail" href="{$BASE_URL}{$MODELS}/{$model.id}">
            <img src="{$BASE_URL}thumbnails/{$model.id}.png" alt="..." onError="this.src='http://placehold.it/290x193&amp;text=Model';" style="width: 290px; height: 193px;">
        </a>
    </div>
    <div class="col-xs-12 col-sm-12 col-md-2">
        <ul class="meta-search">
            <li>
                <i class="glyphicon glyphicon-calendar"></i>
                <time class="timeago" datetime="{$model.createdate}">{$model.createdate}</time>
            </li>
            <li>
                <i class="glyphicon glyphicon-tags"> </i>
                <span>Model</span>
            </li>
        </ul>
    </div>
    <div class="col-xs-12 col-sm-12 col-md-7">
        <h3>
            <a class="dynamic_load" href="{$BASE_URL}{$MODELS}/{$model.id}">{$model.name}</a>
        </h3>
        <p class="about">{$model.description}</p>
    </div>
    <span class="clearfix"></span>
</article>