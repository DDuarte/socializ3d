    /* Morris.js Charts */
    // Sales chart
    var area = new Morris.Area({
        element: 'revenue-chart',
        resize: true,
        data: [
            {date: '2011 Q1', users: 2666, groups: 2666, models: 7666},
            {date: '2011 Q2', users: 2778, groups: 2294, models: 7294},
            {date: '2011 Q3', users: 4912, groups: 1969, models: 7969},
            {date: '2011 Q4', users: 3767, groups: 3597, models: 7597},
            {date: '2012 Q1', users: 6810, groups: 1914, models: 7914},
            {date: '2012 Q2', users: 5670, groups: 4293, models: 7293},
            {date: '2012 Q3', users: 4820, groups: 3795, models: 7795},
            {date: '2012 Q4', users: 15073,groups: 5967, models: 7967},
            {date: '2013 Q1', users: 10687,groups: 4460, models: 7460},
            {date: '2013 Q2', users: 8432, groups: 5713, models: 7713}
        ],
        xkey: 'date',
        ykeys: ['users', 'groups', 'models'],
        labels: ['Users', 'Groups', 'Models'],
        lineColors: ['#a0d0e0', '#3c8dbc', '#ffba00'],
        hideHover: 'auto'
    });
