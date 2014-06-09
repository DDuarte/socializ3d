$(function() {
    // Instance the tour
    function startIntro(){
        var intro = introJs();
        intro.setOptions({
            steps: [
                {
                    intro: "In the catalog page, you have access to the community models."
                },
                {
                    element: document.querySelector('#whatsHot'),
                    intro: "Access recently popular models."
                },
                {
                    element: document.querySelector('#topRated'),
                    intro: "Access the top rated models."
                },
                {
                    element: document.querySelector('#new'),
                    intro: "Access the most recent models."
                },
                {
                    element: document.querySelector('#random'),
                    intro: "Feeling lucky? Search for random models!"
                }
            ]
        });

        intro.start();
    }

    $('#helpBtn').show().click(function(event) {
        console.log("StartIntro");
        startIntro();
    });
});