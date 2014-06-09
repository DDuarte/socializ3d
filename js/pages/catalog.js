$(function() {
    // Instance the tour
    function startIntro(){
        var intro = introJs();
        var options = { steps: [] };

        options.steps.push({
            intro: "In the catalog page, you have access to the community models."
        });
        options.steps.push({
            element: document.querySelector('#whatsHot'),
            intro: "Access recently popular models."
        });
        options.steps.push({
            element: document.querySelector('#topRated'),
            intro: "Access the top rated models."
        });
        options.steps.push({
            element: document.querySelector('#new'),
            intro: "Access the most recent models."
        });
        options.steps.push({
            element: document.querySelector('#random'),
            intro: "Feeling lucky? Search for random models!"
        });

        if ($('#notifications-icon').length > 0) {
            options.steps.push({
                element: document.querySelector('#notifications-icon'),
                intro: "View the latest notifications from your friends and groups.",
                'data-position': 'left'
            });
        }
        intro.setOptions(options);
        intro.start();
    }

    $('#helpBtn').show().click(function(event) {
        console.log("StartIntro");
        startIntro();
    });
});