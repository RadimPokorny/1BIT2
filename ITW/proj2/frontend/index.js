// Display the current date
var currentTime = new Date()
let copyright = document.getElementById("copyright");

copyright.textContent = "© " + currentTime.getFullYear().toString() + " Radim Pokorný";


// Get the button:
let mybutton = document.getElementById("up-btn");

// When the user scrolls down 20px from the top of the document, show the button
window.onscroll = function() {scrollFunction()};

function scrollFunction() {
  if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
    mybutton.style.display = "flex";
  } else {
    mybutton.style.display = "none";
  }
}

// When the user clicks on the button, scroll to the top of the document
function topFunction() {
  document.body.scrollTop = 0; // For Safari
  document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
}

//Navbar responsivity behavior logic
document.addEventListener('DOMContentLoaded', function() {
  const hamburger = document.getElementById('hamburger');
  const linkGroup = document.getElementById('link-group');
  
  hamburger.addEventListener('click', function() {
    linkGroup.classList.toggle('active');
      
    // Change icons
    const icon = hamburger.querySelector('i');
    if (linkGroup.classList.contains('active')) {
        icon.classList.remove('fa-bars');
        icon.classList.add('fa-times');
    } else {
        icon.classList.remove('fa-times');
        icon.classList.add('fa-bars');
    }
  });
  
  // Close menu when a link is clicked (mobile)
  const navLinks = linkGroup.querySelectorAll('a');
  navLinks.forEach(link => {
    link.addEventListener('click', function() {
      if (window.innerWidth <= 768) {
        linkGroup.classList.remove('active');
        const icon = hamburger.querySelector('i');
        icon.classList.remove('fa-times');
        icon.classList.add('fa-bars');
      }
    });
  });
});

//jQuery code for cursor animation

$(document).ready(function(){
  let mouseX = 0, mouseY = 0;
  let posX = 0, posY = 0;
  let bgPosX = 0, bgPosY = 0;

  $(document).on("mousemove", function(e){
    mouseX = e.pageX;
    mouseY = e.pageY;
  });

  function animateFollower() {
    // malé kolečko
    posX += (mouseX - posX) / 8;
    posY += (mouseY - posY) / 8;

    $("#follower").css({
      left: posX + "px",
      top: posY + "px"
    });

    // větší kolečko
    bgPosX += (mouseX - bgPosX) / 30; // pomalejší
    bgPosY += (mouseY - bgPosY) / 30;

    $("#second-follower").css({
      left: bgPosX + "px",
      top: bgPosY + "px"
    });

    requestAnimationFrame(animateFollower);
  }

  animateFollower();
});
