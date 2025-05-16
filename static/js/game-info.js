document.addEventListener('DOMContentLoaded', function() {
    // Video Carousel Functionality
    const videoItems = document.querySelectorAll('.video-item');
    const indicators = document.querySelectorAll('.indicator');
    const prevBtn = document.querySelector('.carousel-control.prev');
    const nextBtn = document.querySelector('.carousel-control.next');
    let currentIndex = 0;

    function showVideo(index) {
        // Hide all videos
        videoItems.forEach(item => item.classList.remove('active'));
        indicators.forEach(ind => ind.classList.remove('active'));
        
        // Show selected video
        videoItems[index].classList.add('active');
        indicators[index].classList.add('active');
        currentIndex = index;
    }

    // Event listeners for indicators
    indicators.forEach((indicator, index) => {
        indicator.addEventListener('click', () => {
            showVideo(index);
        });
    });

    // Event listeners for prev/next buttons
    prevBtn.addEventListener('click', () => {
        let newIndex = currentIndex - 1;
        if (newIndex < 0) newIndex = videoItems.length - 1;
        showVideo(newIndex);
    });

    nextBtn.addEventListener('click', () => {
        let newIndex = currentIndex + 1;
        if (newIndex >= videoItems.length) newIndex = 0;
        showVideo(newIndex);
    });

    // Music Player Functionality
    const audioPlayer = document.getElementById('audio-player');
    const trackItems = document.querySelectorAll('.track-item');
    const playButtons = document.querySelectorAll('.play-btn');
    const prevTrackBtn = document.getElementById('prev-track');
    const nextTrackBtn = document.getElementById('next-track');
    let currentTrackIndex = 0;

    function playTrack(index) {
        // Update active track
        trackItems.forEach(item => item.classList.remove('active'));
        trackItems[index].classList.add('active');
        
        // Update audio source
        const trackSrc = trackItems[index].getAttribute('data-src');
        audioPlayer.src = trackSrc;
        audioPlayer.play();
        
        // Update play button text
        playButtons.forEach((btn, i) => {
            btn.textContent = i === index ? 'Pause' : 'Play';
        });
        
        currentTrackIndex = index;
    }

    // Event listeners for track items
    trackItems.forEach((track, index) => {
        const playBtn = track.querySelector('.play-btn');
        
        playBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            
            if (currentTrackIndex === index && !audioPlayer.paused) {
                // Pause current track
                audioPlayer.pause();
                playBtn.textContent = 'Play';
            } else {
                // Play selected track
                playTrack(index);
            }
        });
        
        track.addEventListener('click', () => {
            playTrack(index);
        });
    });

    // Event listeners for prev/next track buttons
    prevTrackBtn.addEventListener('click', () => {
        let newIndex = currentTrackIndex - 1;
        if (newIndex < 0) newIndex = trackItems.length - 1;
        playTrack(newIndex);
    });

    nextTrackBtn.addEventListener('click', () => {
        let newIndex = currentTrackIndex + 1;
        if (newIndex >= trackItems.length) newIndex = 0;
        playTrack(newIndex);
    });

    // Handle audio ended event
    audioPlayer.addEventListener('ended', () => {
        let newIndex = currentTrackIndex + 1;
        if (newIndex >= trackItems.length) newIndex = 0;
        playTrack(newIndex);
    });

    // Update play button when audio is paused
    audioPlayer.addEventListener('pause', () => {
        playButtons[currentTrackIndex].textContent = 'Play';
    });

    // Update play button when audio is played
    audioPlayer.addEventListener('play', () => {
        playButtons[currentTrackIndex].textContent = 'Pause';
    });

    // Screenshot carousel functionality
    const track = document.querySelector('.carousel-track');
    const slides = Array.from(document.querySelectorAll('.carousel-slide'));
    const screenshotNextBtn = document.querySelector('.next-arrow');
    const screenshotPrevBtn = document.querySelector('.prev-arrow');
    const screenshotIndicators = document.querySelectorAll('.carousel-indicators .indicator');
    const container = document.querySelector('.carousel-container');
    const captionTitle = document.getElementById('screenshot-title');
    const captionDescription = document.getElementById('screenshot-description');
    
    // Screenshot data (titles and descriptions)
    const screenshotData = [
        {
            title: "Improve your character",
            description: "Purchase upgrades in the Safe Zone and prepare for adventure."
        },
        {
            title: "Fight and survive",
            description: "The levels are full of enemies and traps, learn and improve to advance."
        },
        {
            title: "Come in and explore",
            description: "The levels are full of secrets. Will you find them all?"
        },
        {
            title: "Choose your character",
            description: "Select your favorite character and guide him to victory."
        },
        {
            title: "Death is not the end",
            description: "Dying is part of the process, start over, improve and learn."
        }
    ];
    
    let screenshotCurrentIndex = 0;
    let startPos = 0;
    let currentTranslate = 0;
    let prevTranslate = 0;
    let isDragging = false;
    let animationID = 0;
    let autoplayInterval;
    
    // Initialize the carousel if elements exist
    if (track && slides.length > 0) {
        initializeCarousel();
    }
    
    // Initialize the carousel
    function initializeCarousel() {
        updateSlidePositions();
        startAutoplay();
        
        // Event listeners
        screenshotNextBtn.addEventListener('click', () => {
            moveToSlide(screenshotCurrentIndex + 1);
            resetAutoplay();
        });
        
        screenshotPrevBtn.addEventListener('click', () => {
            moveToSlide(screenshotCurrentIndex - 1);
            resetAutoplay();
        });
        
        screenshotIndicators.forEach((indicator, index) => {
            indicator.addEventListener('click', () => {
                moveToSlide(index);
                resetAutoplay();
            });
        });
        
        // Touch events for dragging
        container.addEventListener('mousedown', dragStart);
        container.addEventListener('touchstart', dragStart);
        container.addEventListener('mouseup', dragEnd);
        container.addEventListener('touchend', dragEnd);
        container.addEventListener('mouseleave', dragEnd);
        container.addEventListener('mousemove', drag);
        container.addEventListener('touchmove', drag);
    }
    
    // Update slide positions (prev, active, next)
    function updateSlidePositions() {
        slides.forEach((slide, index) => {
            slide.classList.remove('active', 'prev', 'next');
            
            if (index === screenshotCurrentIndex) {
                slide.classList.add('active');
            } else if (index === getPrevIndex()) {
                slide.classList.add('prev');
            } else if (index === getNextIndex()) {
                slide.classList.add('next');
            }
        });
        
        // Update indicators
        screenshotIndicators.forEach((indicator, index) => {
            indicator.classList.toggle('active', index === screenshotCurrentIndex);
        });
        
        // Update caption
        updateCaption();
    }
    
    // Get previous slide index with wrap-around
    function getPrevIndex() {
        return (screenshotCurrentIndex - 1 + slides.length) % slides.length;
    }
    
    // Get next slide index with wrap-around
    function getNextIndex() {
        return (screenshotCurrentIndex + 1) % slides.length;
    }
    
    // Move to a specific slide
    function moveToSlide(index) {
        // Handle wrap-around
        if (index < 0) {
            index = slides.length - 1;
        } else if (index >= slides.length) {
            index = 0;
        }
        
        screenshotCurrentIndex = index;
        updateSlidePositions();
    }
    
    // Update the caption based on current slide
    function updateCaption() {
        if (screenshotData[screenshotCurrentIndex]) {
            const data = screenshotData[screenshotCurrentIndex];
            captionTitle.textContent = data.title;
            captionDescription.textContent = data.description;
        }
    }
    
    // Start autoplay
    function startAutoplay() {
        autoplayInterval = setInterval(() => {
            moveToSlide(screenshotCurrentIndex + 1);
        }, 20000); // 20 seconds
    }
    
    // Reset autoplay timer
    function resetAutoplay() {
        clearInterval(autoplayInterval);
        startAutoplay();
    }
    
    // Drag functionality
    function dragStart(event) {
        if (event.type === 'touchstart') {
            startPos = event.touches[0].clientX;
        } else {
            startPos = event.clientX;
            event.preventDefault();
        }
        
        isDragging = true;
        container.classList.add('dragging');
        animationID = requestAnimationFrame(animation);
    }
    
    function drag(event) {
        if (isDragging) {
            let currentPosition = 0;
            if (event.type === 'touchmove') {
                currentPosition = event.touches[0].clientX;
            } else {
                currentPosition = event.clientX;
            }
            
            currentTranslate = prevTranslate + currentPosition - startPos;
        }
    }
    
    function dragEnd() {
        cancelAnimationFrame(animationID);
        isDragging = false;
        container.classList.remove('dragging');
        
        const movedBy = currentTranslate - prevTranslate;
        
        // If dragged enough to the right, go to previous slide
        if (movedBy > 100) {
            moveToSlide(screenshotCurrentIndex - 1);
        }
        // If dragged enough to the left, go to next slide
        else if (movedBy < -100) {
            moveToSlide(screenshotCurrentIndex + 1);
        }
        
        prevTranslate = 0;
        currentTranslate = 0;
        resetAutoplay();
    }
    
    function animation() {
        if (isDragging) {
            // We're not actually moving the slides during drag
            // Just tracking the movement amount
            animationID = requestAnimationFrame(animation);
        }
    }
});

// Añadir este código al archivo game-info.js existente

// Funcionalidad de paginación para la lista de canciones
document.addEventListener('DOMContentLoaded', function() {
    const trackItems = document.querySelectorAll('.track-item');
    const pageIndicators = document.querySelectorAll('.page-indicator');
    const prevPageBtn = document.getElementById('prev-page');
    const nextPageBtn = document.getElementById('next-page');
    let currentPage = 1;
    const totalPages = pageIndicators.length;
    
    // Función para mostrar una página específica
    function showPage(pageNum) {
        // Ocultar todas las canciones
        trackItems.forEach(item => {
            item.style.display = 'none';
        });
        
        // Mostrar solo las canciones de la página actual
        const currentPageTracks = document.querySelectorAll(`.track-item[data-page="${pageNum}"]`);
        currentPageTracks.forEach(item => {
            item.style.display = 'flex';
        });
        
        // Actualizar indicadores de página
        pageIndicators.forEach(indicator => {
            indicator.classList.remove('active');
            if (parseInt(indicator.getAttribute('data-page')) === pageNum) {
                indicator.classList.add('active');
            }
        });
        
        // Actualizar estado de los botones de navegación
        prevPageBtn.disabled = pageNum === 1;
        nextPageBtn.disabled = pageNum === totalPages;
        
        currentPage = pageNum;
    }
    
    // Event listeners para los indicadores de página
    pageIndicators.forEach(indicator => {
        indicator.addEventListener('click', () => {
            const pageNum = parseInt(indicator.getAttribute('data-page'));
            showPage(pageNum);
        });
    });
    
    // Event listeners para los botones de navegación
    prevPageBtn.addEventListener('click', () => {
        if (currentPage > 1) {
            showPage(currentPage - 1);
        }
    });
    
    nextPageBtn.addEventListener('click', () => {
        if (currentPage < totalPages) {
            showPage(currentPage + 1);
        }
    });
    
    // Inicializar la primera página
    showPage(1);
    
    // Asegurarse de que la canción activa esté visible
    const activeTrack = document.querySelector('.track-item.active');
    if (activeTrack) {
        const activePage = parseInt(activeTrack.getAttribute('data-page'));
        showPage(activePage);
    }
});