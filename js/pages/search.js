$(document).ready(function () {

    $(".tabs-bar a.tab-link").click(function (event) {
        event.preventDefault();
        var elem = $(this);
        var filter = $(elem.context).data('filter');
        elem.parent().siblings('.active').removeClass('active');
        elem.parent().addClass('active');
        $('#search_results article.search-result').addClass('hidden');
        if (filter == "") {
            $('#search_results article').removeClass('hidden');
            delete Socializ3d.hash.filter;
        }
        else {
            $('#search_results article.' + filter).removeClass('hidden');
            Socializ3d.hash.filter = filter;
        }

        Socializ3d.update_hash();
    });

    if (Socializ3d.hash.filter !== undefined) {
        $(".tabs-bar a.tab-link[data-filter='" + Socializ3d.hash.filter + "']").trigger("click");
    } else {
        $(".tabs-bar a.tab-link[data-filter='']").trigger("click");
    }

    var tabs = $(".tabs-bar a.tab-link").each(function (number, element) {
        var elem = $(element);
        var str = "#";
        if (Socializ3d.hash !== undefined) {
            Object.keys(Socializ3d.hash).forEach(function (key) {
                if (key != "filter") {
                    // alert(key);
                    str += key + '_' + Socializ3d.hash[key] + '-';
                } else if (elem.data('filter') != "") {
                    str += 'filter_' + elem.data('filter') + '-';
                }
            });
        }
        if (Socializ3d.hash.filter === undefined && elem.data('filter') != "") {
            str += 'filter_' + elem.data('filter') + '-';
        }

        elem.attr('href', str.slice(0, -1));
    });
});

