$.extend({
    reInitPopUps : function( id ){
        //add the class of hover to all elements with the class of col2
        $("#"+id+" .col2").hover(
        function(){
            if (this.title > " "){
                this.tip = this.title;
                this.title = "";
                $(['<div id="tooltip">',this.tip,'</div>'].join("")).css( {
                position: 'absolute',
                width: '400px',
                top: event.clientY+20,
                left: event.clientX+40,
                'font-weight': 'bold',
                border: '1px solid #000',
                padding: '10px 10px 10px 10px',
                'background-color': '#ffc',
                opacity: 1.00
                }).appendTo("body").fadeIn(0);	
            }      
        },
        function(){
            if (this.tip > " "){
                $("#tooltip").remove(); 
                this.title = this.tip;
            }
        });	
    }});

$(document).ready(function() {
    $('.toggleButton').click(function() {
        if ($(this).siblings("div:first").is(":hidden"))
        {
            $(this).html("-");
            $(this).siblings("div:first").slideDown("fast");
        }
        else
        {
            $(this).html("+");
            $(this).siblings("div:first").slideUp("fast");
        }
    });
});
    
    