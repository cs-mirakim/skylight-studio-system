// sidebar.js - ES5 Compatible Version with Fixed Role Detection
// Compatible dengan NetBeans 8.2

var menus = {
    instructor: [
        {label: 'Profile', href: '../general/profile.jsp'},
        {label: 'Dashboard', href: '../instructor/dashboard_instructor.jsp'},
        {label: 'Schedule (Class List)', href: '../instructor/schedule_instructor.jsp'},
        {label: 'Inbox Messages', href: '../instructor/inboxMessages_instructor.jsp', badgeId: 'inbox'},
        {label: 'Privacy Policy', href: '../general/privacy_policy.jsp'}
    ],
    admin: [
        {label: 'Profile', href: '../general/profile.jsp'},
        {label: 'Dashboard', href: '../admin/dashboard_admin.jsp'},
        {label: 'Class List', href: '../admin/schedule_admin.jsp'},
        {label: 'Monitor Instructor', href: '../admin/monitor_instructor.jsp'},
        {label: 'Review Registration', href: '../admin/review_registration.jsp'},
        {label: 'Inbox Messages', href: '../admin/inboxMessages_admin.jsp', badgeId: 'inbox'},
        {label: 'Privacy Policy', href: '../general/privacy_policy.jsp'}
    ]
};

function initSidebar() {
    var sidebar = document.getElementById('sidebar');
    var overlay = document.getElementById('sidebar-overlay');
    var menuContainer = document.getElementById('sidebar-menu');
    var closeBtn = document.getElementById('sidebarClose');

    if (!sidebar || !overlay || !menuContainer) {
        console.warn('Sidebar elements not found');
        return;
    }

    // Get user role from sidebar data attribute (most reliable)
    function getCurrentUserRole() {
        var roleFromAttr = sidebar.getAttribute('data-user-role');
        if (roleFromAttr) {
            console.log('User role from sidebar attribute:', roleFromAttr);
            return roleFromAttr;
        }

        console.warn('No role detected, defaulting to admin');
        return 'admin'; // default fallback
    }

    // Get inbox count from sidebar data attribute
    function getInboxCount() {
        var count = sidebar.getAttribute('data-inbox-count');
        return count ? parseInt(count, 10) : 0;
    }

    // Render menu based on role
    function renderMenu(role) {
        console.log('Rendering menu for role:', role);
        menuContainer.innerHTML = '';

        var items = menus[role];
        if (!items || items.length === 0) {
            console.error('No menu items found for role:', role);
            return;
        }

        var inboxCount = getInboxCount();
        console.log('Inbox count:', inboxCount);

        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            var container = document.createElement('div');
            container.className = "flex flex-col";

            var el;
            if (item.href) {
                el = document.createElement('a');
                el.href = item.href;
            } else {
                el = document.createElement('button');
                el.type = 'button';
            }

            el.className = 'w-full flex items-center justify-between px-4 py-4 hover:bg-cloud transition-colors group';

            // Determine badge count
            var badgeCount = 0;
            if (item.badgeId === 'inbox') {
                badgeCount = inboxCount;
            }

            var badgeHtml = '';
            if (badgeCount > 0) {
                badgeHtml = '<span class="ml-2 px-2 py-0.5 text-[10px] font-bold bg-dusty text-whitePure rounded-full shadow-sm group-hover:bg-espresso transition-colors">' +
                        badgeCount +
                        '</span>';
            }

            el.innerHTML = '<div class="flex items-center">' +
                    '<span class="text-sm font-semibold text-espresso/90 group-hover:text-dusty">' + item.label + '</span>' +
                    badgeHtml +
                    '</div>' +
                    '<svg class="w-4 h-4 text-dusty/40 group-hover:text-dusty transition-all transform group-hover:translate-x-1" fill="none" stroke="currentColor" stroke-width="3" viewBox="0 0 24 24">' +
                    '<path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"></path>' +
                    '</svg>';

            container.appendChild(el);

            var hr = document.createElement('div');
            hr.className = 'border-t border-espresso/10 w-full';
            container.appendChild(hr);

            menuContainer.appendChild(container);
        }

        console.log('Menu rendered successfully for', role);
    }

    // Open sidebar
    function openSidebar() {
        sidebar.classList.remove('-translate-x-full');
        overlay.classList.remove('hidden');
        sidebar.setAttribute('aria-hidden', 'false');
    }

    // Close sidebar
    function closeSidebar() {
        sidebar.classList.add('-translate-x-full');
        overlay.classList.add('hidden');
        sidebar.setAttribute('aria-hidden', 'true');
    }

    // Event listeners
    var sidebarBtn = document.getElementById('sidebarBtn');
    if (sidebarBtn) {
        sidebarBtn.addEventListener('click', openSidebar);
    }

    if (closeBtn) {
        closeBtn.addEventListener('click', closeSidebar);
    }

    overlay.addEventListener('click', closeSidebar);

    // Initial render based on user role
    var initialRole = getCurrentUserRole();
    console.log('Initial role detected:', initialRole);
    renderMenu(initialRole);

    // Global function to update badge from header
    window.updateSidebarBadge = function (count) {
        console.log('Updating sidebar badge to:', count);
        sidebar.setAttribute('data-inbox-count', count);
        var currentRole = getCurrentUserRole();
        renderMenu(currentRole);
    };
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', initSidebar);
