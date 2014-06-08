<div class="thumbnail center-block" style="max-width:300px">
    <a class="dynamic_load" href="{$BASE_URL}{$MODELS}/{$model.id}" >
        <img src="{if $model.hasThumbnail}{$BASE_URL}thumbnails/{$model.id}.png{else}http://placehold.it/290x193&text=Model{/if}" alt="..." style="width: 290px; height: 193px;">
    </a>
    <div class="caption center-block" style="margin-top:-30px;position:relative;padding-bottom:0">
        <p>
            <span class="fa fa-comment-o"></span>
            <a class="dynamic_load" href="{$BASE_URL}{$MODELS}/{$model.id}#tab_comments">{$model.numcomments} comment{if $model.numcomments != 1}s{/if}</a>
            <span class="fa fa-thumbs-down pull-right text-red">{$model.numdownvotes}</span>
            <span class="fa fa-thumbs-up text-right pull-right text-green">{$model.numupvotes}</span>
        </p>
        <a class="dynamic_load" href="{$BASE_URL}{$MODELS}/{$model.id}"><h4 style="margin:0">{$model.name}</h4></a>
        <div class="user-panel">
            <div class="pull-left image">
                <img src="{$GRAVATAR_URL}{$model.authorhash}?d=identicon" class="img-square" alt="User Image" />
            </div>
            <div class="pull-left info">
                <p><a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$model.idauthor}">{$model.authorname}</a></p>
                <p>
                    <time class="timeago" datetime="{$model.createdate}">{$model.createdate}</time>
                </p>
            </div>
        </div>
    </div>
</div>