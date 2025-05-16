document.addEventListener('DOMContentLoaded', function() {
    const sortSelect = document.getElementById('sort-posts');
    const postsContainer = document.querySelector('.blog-posts-container');
    const postsPerPageSelect = document.getElementById('posts-per-page-select');
    const prevPageBtn = document.getElementById('prev-page');
    const nextPageBtn = document.getElementById('next-page');
    const pageNumbersContainer = document.querySelector('.page-numbers');
    
    let currentPage = 1;
    let postsPerPage = parseInt(postsPerPageSelect.value);
    let allPosts = [];
    
    // Inicializar
    function init() {
        if (postsContainer) {
            allPosts = Array.from(postsContainer.querySelectorAll('.blog-post'));
            
            // Ordenar posts inicialmente
            sortPosts(sortSelect.value);
            
            // Configurar paginación
            updatePagination();
            showPage(currentPage);
            
            // Event listeners
            if (sortSelect) {
                sortSelect.addEventListener('change', function() {
                    sortPosts(this.value);
                    showPage(1); // Volver a la primera página al cambiar el orden
                });
            }
            
            if (postsPerPageSelect) {
                postsPerPageSelect.addEventListener('change', function() {
                    postsPerPage = parseInt(this.value);
                    updatePagination();
                    showPage(1); // Volver a la primera página al cambiar posts por página
                });
            }
            
            if (prevPageBtn) {
                prevPageBtn.addEventListener('click', function() {
                    if (currentPage > 1) {
                        showPage(currentPage - 1);
                    }
                });
            }
            
            if (nextPageBtn) {
                nextPageBtn.addEventListener('click', function() {
                    const totalPages = Math.ceil(allPosts.length / postsPerPage);
                    if (currentPage < totalPages) {
                        showPage(currentPage + 1);
                    }
                });
            }
        }
    }
    
    // Función para ordenar los posts
    function sortPosts(order) {
        allPosts.sort((a, b) => {
            const dateA = new Date(a.getAttribute('data-date'));
            const dateB = new Date(b.getAttribute('data-date'));
            
            return order === 'newest' ? dateB - dateA : dateA - dateB;
        });
        
        // Eliminar todos los posts actuales
        allPosts.forEach(post => post.remove());
        
        // Añadir los posts ordenados
        allPosts.forEach(post => postsContainer.appendChild(post));
    }
    
    // Actualizar la paginación
    function updatePagination() {
        const totalPages = Math.ceil(allPosts.length / postsPerPage);
        
        // Limpiar números de página existentes
        pageNumbersContainer.innerHTML = '';
        
        // Generar números de página
        for (let i = 1; i <= totalPages; i++) {
            const pageNumber = document.createElement('span');
            pageNumber.classList.add('page-number');
            pageNumber.setAttribute('data-page', i);
            pageNumber.textContent = i;
            
            if (i === currentPage) {
                pageNumber.classList.add('active');
            }
            
            pageNumber.addEventListener('click', function() {
                showPage(i);
            });
            
            pageNumbersContainer.appendChild(pageNumber);
        }
    }
    
    // Mostrar la página especificada
    function showPage(pageNum) {
        currentPage = pageNum;
        
        // Calcular qué posts mostrar
        const startIndex = (currentPage - 1) * postsPerPage;
        const endIndex = startIndex + postsPerPage;
        
        // Ocultar/mostrar posts según corresponda
        allPosts.forEach((post, index) => {
            if (index >= startIndex && index < endIndex) {
                post.classList.remove('hidden');
            } else {
                post.classList.add('hidden');
            }
        });
        
        // Actualizar estado de los botones de navegación
        prevPageBtn.disabled = currentPage === 1;
        nextPageBtn.disabled = currentPage === Math.ceil(allPosts.length / postsPerPage);
        
        // Actualizar clase activa en números de página
        document.querySelectorAll('.page-number').forEach(num => {
            if (parseInt(num.getAttribute('data-page')) === currentPage) {
                num.classList.add('active');
            } else {
                num.classList.remove('active');
            }
        });
        
        // Scroll al inicio de la sección de blog
        document.querySelector('.dev-blog').scrollIntoView({ behavior: 'smooth' });
    }
    
    // Iniciar todo
    init();
});