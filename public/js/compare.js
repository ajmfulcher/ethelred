document.addEventListener("DOMContentLoaded", function(event) {

    var content = '<h3>People mentioned in this story</h3>';

    var personCard = '<div class="person-card">' +
        '<div class="person-photo">' +
        '<img src="" />' +
        '<div class="person-name-caption">Kate Middleton</div>' +
        '</div>' +
        '<p class="person-blurb">blkjlkjalksdjf lkajsdfasd  laksdjf</p>' +
        '<p class="person-fact"><strong>Born:</strong> lkjlkjl</p>' +
        '<p class="person-fact"><strong>Born:</strong> lkjlkjl</p>' +
        '<p class="person-fact"><strong>Born:</strong> lkjlkjl</p>' +
        '</div>';

    var personWrapper = '<div class="person-wrapper">' + personCard + personCard
        '</div>';

    var didYouKnow = '<div class="did-you-know">' +
        '<h3>Did you know...</h3>' +
        '<p>They both went to the University of St Andrews, as did <a href="">King James II</a></p>' +
    '</div>';

    var otherPersonPhoto = '<div class="person-photo">' +
        '<img src="" /><div class="person-name-caption">Kate Middleton</div>' +
    '</div>';

    var otherPeople = '<h3 class="other-people-header"> Other royalty born on the 22nd of July</h3>' +
        '<div class="other-people">' +
        otherPersonPhoto +
        otherPersonPhoto +
        otherPersonPhoto +
        otherPersonPhoto +
        '</div>' +
        '<div style="clear:both"></div>';



    var content = personWrapper + didYouKnow + otherPeople;

    var story = document.querySelector('.story-related');
    if(document.URL.indexOf("/news/") !== -1) {
      story.insertAdjacentHTML('beforebegin', content);
    }



});