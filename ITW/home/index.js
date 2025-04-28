$(document).ready(function() {
    // Menu configuration
    const menuItems = [
        { icon: 'home', text: 'Index', href: '#' },
        { icon: 'info-circle', text: 'O předmětu', href: '#opredmetu' },
        { icon: 'tv', text: 'Přednášky', href: '#prednasky' },
        { icon: 'grin-beam-sweat', text: 'Výsledky', href: '#vysledky' },
        { icon: 'hammer', text: 'Cvičení', href: '#cviceni' },
        { icon: 'envelope', text: 'Kontakt', href: '#kontakt' },
        { icon: 'code-branch', text: 'Související', href: '#souvisejici' }
    ];

    // Create the menu structure
    function createMenu() {
        const $ul = $('.ul-bg ul');
        $ul.empty();
        
        // Add hamburger button for xs screens
        $ul.append('<li class="menu-toggle"><a href="#"><i class="fas fa-bars"></i></a></li>');
        
        // Add menu items
        menuItems.forEach(item => {
            $ul.append(`
                <li class="menu-item">
                    <a href="${item.href}" title="${item.text}">
                        <i class="fas fa-${item.icon}"></i>
                        <span class="menu-text">${item.text}</span>
                    </a>
                </li>
            `);
        });
    }

    // Initialize menu
    createMenu();
    
    // Handle responsive menu behavior
    function updateMenu() {
        const width = $(window).width();
        const $menuItems = $('.menu-item');
        const $menuToggle = $('.menu-toggle');
        
        // Extra small devices - show hamburger menu
        if (width < 576) {
            $menuItems.hide();
            $menuToggle.show();
            $('.ul-bg ul').addClass('mobile-menu');
        } 
        // Small devices - show text only
        else if (width < 768) {
            $menuItems.show();
            $menuToggle.hide();
            $('.menu-text').show();
            $('.ul-bg ul').removeClass('mobile-menu');
            $('.menu-item i').hide();
        } 
        // Medium devices - show icons only, text on hover
        else if (width < 992) {
            $menuItems.show();
            $menuToggle.hide();
            $('.menu-text').hide();
            $('.ul-bg ul').removeClass('mobile-menu');
            $('.menu-item i').show();
            
            // Show text on hover
            $menuItems.hover(
                function() { $(this).find('.menu-text').show(); },
                function() { $(this).find('.menu-text').hide(); }
            );
        } 
        // Large devices - show both icons and text
        else {
            $menuItems.show();
            $menuToggle.hide();
            $('.menu-text').show();
            $('.ul-bg ul').removeClass('mobile-menu');
            $('.menu-item i').show();
        }
    }
    
    // Toggle mobile menu
    $('body').on('click', '.menu-toggle a', function(e) {
        e.preventDefault();
        $('.menu-item').toggle();
    });
    
    // Close mobile menu when clicking a link
    $('body').on('click', '.mobile-menu .menu-item a', function() {
        if ($(window).width() < 576) {
            $('.menu-item').hide();
        }
    });
    
    // Sticky menu functionality
    const $ulBg = $('.ul-bg');
    const ulBgOffset = $ulBg.offset().top;
    
    $(window).scroll(function() {
        if ($(window).width() >= 576) { // Only sticky for non-mobile
            if ($(window).scrollTop() > ulBgOffset) {
                $ulBg.addClass('sticky');
                $('body').css('padding-top', $ulBg.outerHeight() + 'px');
            } else {
                $ulBg.removeClass('sticky');
                $('body').css('padding-top', '0');
            }
        }
    });
    
    // Smooth scrolling with offset for sticky menu
    $('a[href^="#"]').on('click', function(e) {
        e.preventDefault();
        
        const target = $(this.getAttribute('href'));
        if (target.length) {
            let offset = 0;
            if ($ulBg.hasClass('sticky')) {
                offset = $ulBg.outerHeight();
            }
            
            $('html, body').stop().animate({
                scrollTop: target.offset().top - offset
            }, 1000);
        }
    });
    
    // Initialize and update on resize
    updateMenu();
    $(window).resize(function() {
        updateMenu();
    });
});