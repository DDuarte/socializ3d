<div class="thumbnail center-block" style="max-width:300px">
    <a href="{$BASE_URL}model/{$model.id}">
        <img src="http://placehold.it/300x200" alt="...">
    </a>
    <div class="caption center-block" style="margin-top:-30px;position:relative;padding-bottom:0">
        <p>
            <span class="fa fa-comment-o"></span>
            <a class="dynamic_load" href="{$BASE_URL}model/{$model.id}#tab_comments">{$model.numcomments} comment{if $model.numcomments != 1}s{/if}</a>
            <span class="fa fa-thumbs-down pull-right text-red">{$model.numdownvotes}</span>
            <span class="fa fa-thumbs-up text-right pull-right text-green">{$model.numupvotes}</span>
        </p>
        <h4 style="margin:0">{$model.name}</h4>
        <div class="user-panel">
            <div class="pull-left image">
                <img src="{$GRAVATAR_URL}{$model.authorhash}" class="img-square" alt="User Image" />
            </div>
            <div class="pull-left info">
                <p>{$model.authorname}</p>
                <p>
                    <time class="timeago" datetime="{$model.createdate}">{$model.createdate}</time>
                </p>
            </div>
        </div>
    </div>
</div>