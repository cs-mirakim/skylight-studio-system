<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%
    // Check if user is admin
    if (!SessionUtil.checkAdminAccess(session)) {
        // Always redirect to login with appropriate message
        if (!SessionUtil.isLoggedIn(session)) {
            response.sendRedirect("../general/login.jsp?error=access_denied&message=Please_login_to_access_admin_pages");
        } else {
            // If logged in but not admin
            response.sendRedirect("../general/login.jsp?error=admin_access_required&message=Admin_privileges_required_to_access_this_page");
        }
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Admin Inbox Messages Page</title>

        <!-- Font Inter + Lora -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <!-- Tailwind CDN -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Include JSON library -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/json3/3.3.2/json3.min.js"></script>

        <!-- Tailwind Custom Palette -->
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {
                            sans: ['Roboto', 'ui-sans-serif', 'system-ui'],
                            condensed: ['Roboto Condensed', 'ui-sans-serif'],
                            mono: ['Roboto Mono', 'monospace']
                        },
                        colors: {
                            dusty: '#B36D6D',
                            dustyHover: '#965656',
                            blush: '#F2D1D1',
                            blushHover: '#E8BEBE',
                            cloud: '#FDF8F8',
                            whitePure: '#FFFFFF',
                            petal: '#EFE1E1',
                            espresso: '#3D3434',
                            espressoLight: '#5C4F4F',
                            espressoLighter: '#7A6A6A',
                            successText: '#1E3A1E',
                            teal: '#6D9B9B',
                            tealSoft: '#A3C1D6',
                            tealHover: '#557878',
                            successBg: '#D4EDDA',
                            successBorder: '#C3E6CB',
                            successTextDark: '#155724',
                            warningBg: '#FFF3CD',
                            warningBorder: '#FFEEBA',
                            warningText: '#856404',
                            dangerBg: '#F8D7DA',
                            dangerBorder: '#F5C6CB',
                            dangerText: '#721C24',
                            infoBg: '#D1ECF1',
                            infoBorder: '#BEE5EB',
                            infoText: '#0C5460',
                            urgentRed: '#DC2626',
                            urgentBg: '#FEE2E2',
                            highPriority: '#F59E0B',
                            highBg: '#FEF3C7',
                            normalPriority: '#6D9B9B',
                            normalBg: '#E0F2F1',
                            softGray: '#F8F9FA',
                            borderGray: '#E9ECEF'
                        }
                    }
                }
            }
        </script>

        <style>
            .scrollbar-thin::-webkit-scrollbar {
                width: 6px;
                height: 6px;
            }
            .scrollbar-thin::-webkit-scrollbar-track {
                background: #F8F9FA;
            }
            .scrollbar-thin::-webkit-scrollbar-thumb {
                background: #CED4DA;
                border-radius: 3px;
            }
            .scrollbar-thin::-webkit-scrollbar-thumb:hover {
                background: #B36D6D;
            }
            .notification-item {
                transition: all 0.2s ease;
                border-bottom: 1px solid #E9ECEF;
                cursor: pointer;
            }
            .notification-item:last-child {
                border-bottom: none;
            }
            .notification-item:hover {
                background-color: #F8F9FA;
            }
            .notification-item.unread {
                background-color: #F8FAFC;
                position: relative;
            }
            .notification-item.unread::before {
                content: '';
                position: absolute;
                left: 0;
                top: 0;
                bottom: 0;
                width: 3px;
                background-color: #6D9B9B;
            }
            .notification-type-icon {
                width: 36px;
                height: 36px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-right: 12px;
            }
            .notification-type-register {
                background-color: #E0F2F1;
                color: #0D9488;
            }
            .notification-type-cancel {
                background-color: #FEE2E2;
                color: #DC2626;
            }
            .status-chip {
                display: inline-flex;
                align-items: center;
                padding: 4px 10px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: 500;
            }
            .status-pending {
                background-color: #FEF3C7;
                color: #92400E;
            }
            .status-approved {
                background-color: #D1FAE5;
                color: #065F46;
            }
            .status-rejected {
                background-color: #FEE2E2;
                color: #991B1B;
            }
            .notification-tag {
                display: inline-flex;
                align-items: center;
                padding: 3px 8px;
                border-radius: 12px;
                font-size: 11px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .tag-register {
                background-color: #E0F2F1;
                color: #0D9488;
                border: 1px solid #99F6E4;
            }
            .tag-cancel {
                background-color: #FEE2E2;
                color: #DC2626;
                border: 1px solid #FECACA;
            }
            .action-btn {
                padding: 6px 14px;
                border-radius: 6px;
                font-size: 13px;
                font-weight: 500;
                transition: all 0.2s;
                border: 1px solid;
            }
            .action-btn-mark {
                background-color: #6D9B9B;
                color: white;
                border-color: #557878;
            }
            .action-btn-mark:hover {
                background-color: #557878;
            }
            .action-btn-read {
                background-color: #F8F9FA;
                color: #6C757D;
                border-color: #E9ECEF;
            }
            .action-btn-read:hover {
                background-color: #E9ECEF;
            }
            .modal-backdrop {
                background-color: rgba(0, 0, 0, 0.5);
                backdrop-filter: blur(4px);
            }
            .modal-content {
                max-height: 80vh;
                overflow-y: auto;
            }
            .filter-active {
                background-color: #B36D6D !important;
                color: white !important;
                border-color: #965656 !important;
            }
            .toggle-archive-btn {
                background-color: #F8F9FA;
                border: 1px solid #E9ECEF;
                color: #6C757D;
            }
            .toggle-archive-btn:hover {
                background-color: #E9ECEF;
            }
            .toggle-archive-btn.active {
                background-color: #6D9B9B;
                color: white;
                border-color: #557878;
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">

            <div class="w-full bg-whitePure py-6 px-6 md:px-8
                 rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1500px">

                <!-- Page Header -->
                <div class="mb-6 pb-4 border-b border-espresso/10">
                    <div class="flex flex-col md:flex-row md:items-center md:justify-between">
                        <div class="mb-4 md:mb-0">
                            <h1 class="text-2xl font-semibold text-espresso mb-2">
                                Admin Inbox Messages
                            </h1>
                            <p class="text-sm text-espressoLighter">
                                Instructor registrations and class cancellation alerts
                            </p>
                        </div>
                        <div class="flex items-center space-x-3">
                            <button id="refreshBtn" 
                                    class="flex items-center px-4 py-2.5 bg-whitePure border border-borderGray rounded-lg text-espresso hover:bg-softGray transition-colors">
                                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                                </svg>
                                Refresh
                            </button>
                            <div id="unreadBadge" class="hidden flex items-center px-3 py-1.5 bg-dangerBg border border-dangerBorder rounded-full">
                                <svg class="w-4 h-4 text-dangerText mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path>
                                </svg>
                                <span id="unreadCount" class="text-dangerText font-medium">0</span>
                                <span class="text-dangerText ml-1">unread</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Filter Section -->
                <div class="mb-6">
                    <!-- Filter by Type -->
                    <div class="flex flex-wrap items-center gap-4 mb-4">
                        <span class="text-sm font-medium text-espresso">Filter by Type:</span>
                        <div class="flex gap-1">
                            <button id="filterAll" class="filter-btn px-3 py-1.5 bg-whitePure border border-borderGray rounded-lg text-sm text-espresso hover:bg-dusty hover:text-whitePure transition-colors filter-active">
                                All Messages
                            </button>
                            <button id="filterRegister" class="filter-btn px-3 py-1.5 bg-whitePure border border-borderGray rounded-lg text-sm text-espresso hover:bg-dusty hover:text-whitePure transition-colors">
                                Instructor Registrations
                            </button>
                            <button id="filterCancel" class="filter-btn px-3 py-1.5 bg-whitePure border border-borderGray rounded-lg text-sm text-espresso hover:bg-dusty hover:text-whitePure transition-colors">
                                Class Cancellations
                            </button>
                        </div>
                    </div>

                    <!-- Filter by Status -->
                    <div class="flex flex-wrap items-center gap-4 mb-4">
                        <span class="text-sm font-medium text-espresso">Filter by Status:</span>
                        <div class="flex gap-1">
                            <button id="filterAllStatus" class="status-filter-btn px-3 py-1.5 bg-whitePure border border-borderGray rounded-lg text-sm text-espresso hover:bg-dusty hover:text-whitePure transition-colors filter-active">
                                All
                            </button>
                            <button id="filterUnread" class="status-filter-btn px-3 py-1.5 bg-whitePure border border-borderGray rounded-lg text-sm text-espresso hover:bg-dusty hover:text-whitePure transition-colors">
                                Unread
                            </button>
                            <button id="filterRead" class="status-filter-btn px-3 py-1.5 bg-whitePure border border-borderGray rounded-lg text-sm text-espresso hover:bg-dusty hover:text-whitePure transition-colors">
                                Read
                            </button>
                        </div>
                    </div>

                    <!-- Show by -->
                    <div class="flex flex-wrap items-center gap-4">
                        <span class="text-sm font-medium text-espresso">Show by:</span>
                        <div class="flex gap-1">
                            <button id="showActive" class="toggle-archive-btn px-3 py-1.5 bg-whitePure border border-borderGray rounded-lg text-sm text-espresso hover:bg-teal hover:text-whitePure transition-colors active">
                                Active
                            </button>
                            <button id="showArchived" class="toggle-archive-btn px-3 py-1.5 bg-whitePure border border-borderGray rounded-lg text-sm text-espresso hover:bg-teal hover:text-whitePure transition-colors">
                                Archived
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Inbox Container -->
                <div class="flex-1 flex flex-col">
                    <!-- No Notifications Message -->
                    <div id="noNotifications" class="hidden flex-1 flex flex-col items-center justify-center p-12 text-center">
                        <div class="w-20 h-20 bg-blush/20 rounded-full flex items-center justify-center mb-6">
                            <svg class="w-10 h-10 text-espresso/30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path>
                            </svg>
                        </div>
                        <h3 class="text-lg font-medium text-espresso mb-2">No notifications</h3>
                        <p class="text-espressoLighter max-w-sm">You're all caught up! Check back later for new notifications.</p>
                    </div>

                    <!-- Notifications List -->
                    <div id="notificationsList" class="bg-whitePure rounded-lg border border-borderGray overflow-hidden">
                        <!-- Notifications will be loaded here by JavaScript -->
                    </div>

                    <!-- Pagination -->
                    <div id="pagination" class="mt-6 flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
                        <div class="text-sm text-espressoLighter">
                            Showing <span id="startRow">0</span> to <span id="endRow">0</span> of <span id="totalRows">0</span> notifications
                        </div>
                        <div class="flex items-center space-x-2">
                            <button id="prevPage" class="px-3 py-2 border border-borderGray rounded text-espressoLighter hover:bg-softGray disabled:opacity-40 disabled:cursor-not-allowed transition-colors flex items-center">
                                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                                </svg>
                                Previous
                            </button>
                            <div id="pageNumbers" class="flex space-x-1">
                                <!-- Page numbers will be inserted here -->
                            </div>
                            <button id="nextPage" class="px-3 py-2 border border-borderGray rounded text-espressoLighter hover:bg-softGray disabled:opacity-40 disabled:cursor-not-allowed transition-colors flex items-center">
                                Next
                                <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>

            </div>

        </main>

        <!-- Modal for Viewing Notification Details -->
        <div id="notificationModal" class="hidden fixed inset-0 z-50 overflow-y-auto">
            <div class="modal-backdrop fixed inset-0"></div>
            <div class="flex items-center justify-center min-h-screen p-4">
                <div class="modal-content relative bg-whitePure rounded-lg shadow-xl max-w-2xl w-full mx-auto">
                    <!-- Modal header -->
                    <div class="flex items-center justify-between p-6 border-b border-borderGray">
                        <div class="flex items-center">
                            <div id="modalIcon" class="notification-type-icon mr-3"></div>
                            <div>
                                <h3 id="modalTitle" class="text-lg font-semibold text-espresso"></h3>
                                <p id="modalSubtitle" class="text-sm text-espressoLighter"></p>
                            </div>
                        </div>
                        <button id="closeModal" class="text-espressoLighter hover:text-espresso transition-colors">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </button>
                    </div>

                    <!-- Modal body -->
                    <div class="p-6">
                        <div id="modalContent">
                            <!-- Content will be loaded here -->
                        </div>
                    </div>

                    <!-- Modal footer -->
                    <div class="flex items-center justify-between p-6 border-t border-borderGray">
                        <div class="text-sm text-espressoLighter">
                            <span id="modalDate"></span>
                        </div>
                        <div class="flex space-x-3">
                            <button id="markAsReadBtn" class="action-btn action-btn-mark">
                                Mark as Read
                            </button>
                            <button id="archiveBtn" class="action-btn action-btn-read">
                                Archive
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="../util/footer.jsp" />

        <jsp:include page="../util/sidebar.jsp" />

        <script src="../util/sidebar.js"></script>

        <script>
        // Global variables
        var notificationsData = [];
        var filteredData = [];
        var currentPage = 1;
        var itemsPerPage = 10;
        var currentFilter = 'all';
        var currentStatusFilter = 'all';
        var showArchived = false;
        var currentNotificationId = null;
        var currentNotificationType = null;
        var currentNotification = null; // TAMBAH INI

        // DOM elements
        var notificationsList = document.getElementById('notificationsList');
        var noNotifications = document.getElementById('noNotifications');
        var pagination = document.getElementById('pagination');
        var pageNumbers = document.getElementById('pageNumbers');
        var prevPageBtn = document.getElementById('prevPage');
        var nextPageBtn = document.getElementById('nextPage');
        var startRowSpan = document.getElementById('startRow');
        var endRowSpan = document.getElementById('endRow');
        var totalRowsSpan = document.getElementById('totalRows');
        var refreshBtn = document.getElementById('refreshBtn');
        var unreadBadge = document.getElementById('unreadBadge');
        var unreadCountSpan = document.getElementById('unreadCount');

        // Modal elements
        var notificationModal = document.getElementById('notificationModal');
        var modalIcon = document.getElementById('modalIcon');
        var modalTitle = document.getElementById('modalTitle');
        var modalSubtitle = document.getElementById('modalSubtitle');
        var modalContent = document.getElementById('modalContent');
        var modalDate = document.getElementById('modalDate');
        var closeModal = document.getElementById('closeModal');
        var markAsReadBtn = document.getElementById('markAsReadBtn');
        var archiveBtn = document.getElementById('archiveBtn');

        // Filter elements
        var filterAll = document.getElementById('filterAll');
        var filterRegister = document.getElementById('filterRegister');
        var filterCancel = document.getElementById('filterCancel');
        var filterAllStatus = document.getElementById('filterAllStatus');
        var filterUnread = document.getElementById('filterUnread');
        var filterRead = document.getElementById('filterRead');
        var showActive = document.getElementById('showActive');
        var showArchivedBtn = document.getElementById('showArchived');

        function init() {
            loadNotifications();
            setupEventListeners();
            setupModalListeners();
            setupFilterListeners();
        }

        function setupEventListeners() {
            refreshBtn.addEventListener('click', function () {
                loadNotifications();
            });

            prevPageBtn.addEventListener('click', function () {
                if (currentPage > 1) {
                    currentPage--;
                    loadNotifications(); // PERUBAHAN: Gunakan loadNotifications bukan renderNotifications
                }
            });

            nextPageBtn.addEventListener('click', function () {
                var totalPages = Math.ceil(filteredData.length / itemsPerPage);
                if (currentPage < totalPages) {
                    currentPage++;
                    loadNotifications(); // PERUBAHAN: Gunakan loadNotifications
                }
            });
        }

        function setupModalListeners() {
            closeModal.addEventListener('click', function () {
                notificationModal.classList.add('hidden');
            });

            // PERUBAHAN: Update event listeners untuk markAsReadBtn
            markAsReadBtn.addEventListener('click', function () {
                if (currentNotificationId && currentNotificationType && currentNotification) {
                    if (currentNotification.isRead) {
                        console.log('Marking as UNREAD:', currentNotificationId, currentNotificationType);
                        markAsUnread(currentNotificationId, currentNotificationType);
                    } else {
                        console.log('Marking as READ:', currentNotificationId, currentNotificationType);
                        markAsRead(currentNotificationId, currentNotificationType);
                    }
                } else {
                    console.error('No notification selected or currentNotification not set');
                }
            });

            // PERUBAHAN: Update event listeners untuk archiveBtn
            archiveBtn.addEventListener('click', function () {
                if (currentNotificationId && currentNotificationType && currentNotification) {
                    var currentlyArchived = currentNotification.archived || false;
                    console.log('Archive status:', currentlyArchived);
                    if (currentlyArchived) {
                        console.log('UNARCHIVING:', currentNotificationId, currentNotificationType);
                        toggleArchive(currentNotificationId, currentNotificationType, true);
                    } else {
                        console.log('ARCHIVING:', currentNotificationId, currentNotificationType);
                        toggleArchive(currentNotificationId, currentNotificationType, false);
                    }
                } else {
                    console.error('No notification selected or currentNotification not set');
                }
            });

            // Close modal when clicking on backdrop
            notificationModal.addEventListener('click', function (e) {
                if (e.target.classList.contains('modal-backdrop')) {
                    notificationModal.classList.add('hidden');
                }
            });
        }

        function setupFilterListeners() {
            // Type filters
            filterAll.addEventListener('click', function () {
                currentFilter = 'all';
                updateActiveFilterButtons();
                applyFilters();
            });

            filterRegister.addEventListener('click', function () {
                currentFilter = 'register';
                updateActiveFilterButtons();
                applyFilters();
            });

            filterCancel.addEventListener('click', function () {
                currentFilter = 'cancel';
                updateActiveFilterButtons();
                applyFilters();
            });

            // Status filters
            filterAllStatus.addEventListener('click', function () {
                currentStatusFilter = 'all';
                updateActiveStatusFilterButtons();
                applyFilters();
            });

            filterUnread.addEventListener('click', function () {
                currentStatusFilter = 'unread';
                updateActiveStatusFilterButtons();
                applyFilters();
            });

            filterRead.addEventListener('click', function () {
                currentStatusFilter = 'read';
                updateActiveStatusFilterButtons();
                applyFilters();
            });

            // Archive toggle
            showActive.addEventListener('click', function () {
                showArchived = false;
                updateArchiveButtons();
                applyFilters();
            });

            showArchivedBtn.addEventListener('click', function () {
                showArchived = true;
                updateArchiveButtons();
                applyFilters();
            });
        }

        function updateActiveFilterButtons() {
            var buttons = document.querySelectorAll('.filter-btn');
            for (var i = 0; i < buttons.length; i++) {
                buttons[i].classList.remove('filter-active');
            }

            if (currentFilter === 'all') {
                filterAll.classList.add('filter-active');
            } else if (currentFilter === 'register') {
                filterRegister.classList.add('filter-active');
            } else if (currentFilter === 'cancel') {
                filterCancel.classList.add('filter-active');
            }
        }

        function updateActiveStatusFilterButtons() {
            var buttons = document.querySelectorAll('.status-filter-btn');
            for (var i = 0; i < buttons.length; i++) {
                buttons[i].classList.remove('filter-active');
            }

            if (currentStatusFilter === 'all') {
                filterAllStatus.classList.add('filter-active');
            } else if (currentStatusFilter === 'unread') {
                filterUnread.classList.add('filter-active');
            } else if (currentStatusFilter === 'read') {
                filterRead.classList.add('filter-active');
            }
        }

        function updateArchiveButtons() {
            if (showArchived) {
                showActive.classList.remove('active');
                showArchivedBtn.classList.add('active');
            } else {
                showActive.classList.add('active');
                showArchivedBtn.classList.remove('active');
            }
        }

        function loadNotifications() {
            var url = '../admin/inbox-messages?action=list&type=' + currentFilter + 
                     '&readStatus=' + currentStatusFilter + 
                     '&showArchived=' + (showArchived ? 'true' : 'false') +
                     '&page=' + currentPage + 
                     '&limit=' + itemsPerPage;

            console.log('Loading from URL:', url);

            fetch(url, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json'
                }
            })
            .then(function(response) {
                if (!response.ok) {
                    throw new Error('HTTP error! Status: ' + response.status);
                }
                return response.text();
            })
            .then(function(text) {
                console.log('Response text:', text.substring(0, 200)); // Debug log
                try {
                    var data = JSON.parse(text);

                    if (data.error) {
                        console.error('Error from server:', data.error);
                        showErrorMessage('Server error: ' + data.error);
                        return;
                    }

                    notificationsData = data.notifications || [];
                    filteredData = notificationsData.slice();

                    console.log('Loaded ' + notificationsData.length + ' notifications');
                    if (notificationsData.length > 0) {
                        console.log('First notification:', notificationsData[0]);
                    }

                    renderNotifications();
                    updatePaginationInfo(data.totalCount || 0, data.totalPages || 1);

                    updateUnreadCount();

                } catch (e) {
                    console.error('JSON parse error:', e);
                    showErrorMessage('Invalid response from server');
                }
            })
            .catch(function(error) {
                console.error('Fetch error:', error);
                showErrorMessage('Failed to load notifications: ' + error.message);
            });
        }

        function updateUnreadCount() {
            var url = '../admin/inbox-messages?action=count-unread';

            fetch(url, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json'
                }
            })
            .then(function(response) {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(function(text) {
                console.log('Unread count response:', text);
                try {
                    var data = JSON.parse(text);
                    if (data.error) {
                        console.error('Error loading unread count:', data.error);
                        return;
                    }

                    var unreadCount = data.unreadCount || 0;

                    if (unreadCount > 0) {
                        unreadCountSpan.textContent = unreadCount;
                        unreadBadge.classList.remove('hidden');
                    } else {
                        unreadBadge.classList.add('hidden');
                    }
                } catch (e) {
                    console.error('JSON parse error for unread count:', e);
                }
            })
            .catch(function(error) {
                console.error('Error:', error);
            });
        }

        function applyFilters() {
            currentPage = 1;
            loadNotifications();
        }

        // PERUBAHAN: Function markAsRead yang lebih robust
        function markAsRead(notificationId, type) {
            console.log('markAsRead called with:', notificationId, type);

            var formData = new FormData();
            formData.append('action', 'mark-read');
            formData.append('id', notificationId);
            formData.append('type', type);

            fetch('../admin/inbox-messages', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(function(response) {
                console.log('Response status:', response.status);
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.status);
                }
                return response.text();
            })
            .then(function(text) {
                console.log('Response text:', text);
                try {
                    var data = JSON.parse(text);
                    console.log('Parsed response:', data);

                    if (data.success) {
                        console.log('Successfully marked as read');
                        notificationModal.classList.add('hidden');
                        loadNotifications(); // Reload untuk update status
                    } else {
                        alert('Failed: ' + (data.message || data.error || 'Unknown error'));
                    }
                } catch (e) {
                    console.error('JSON parse error:', e);
                    alert('Invalid response from server');
                }
            })
            .catch(function(error) {
                console.error('Error:', error);
                alert('Failed to mark as read. Please try again.');
            });
        }

        // TAMBAH: Function markAsUnread
        function markAsUnread(notificationId, type) {
            console.log('markAsUnread called with:', notificationId, type);

            var formData = new FormData();
            formData.append('action', 'mark-unread');
            formData.append('id', notificationId);
            formData.append('type', type);

            fetch('../admin/inbox-messages', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(function(response) {
                console.log('Response status:', response.status);
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.status);
                }
                return response.text();
            })
            .then(function(text) {
                console.log('Response text:', text);
                try {
                    var data = JSON.parse(text);
                    console.log('Parsed response:', data);

                    if (data.success) {
                        console.log('Successfully marked as unread');
                        notificationModal.classList.add('hidden');
                        loadNotifications(); // Reload untuk update status
                    } else {
                        alert('Failed: ' + (data.message || data.error || 'Unknown error'));
                    }
                } catch (e) {
                    console.error('JSON parse error:', e);
                    alert('Invalid response from server');
                }
            })
            .catch(function(error) {
                console.error('Error:', error);
                alert('Failed to mark as unread. Please try again.');
            });
        }

        // PERUBAHAN: Function toggleArchive yang lebih jelas
        function toggleArchive(notificationId, type, currentlyArchived) {
            console.log('toggleArchive called with:', notificationId, type, 'currentlyArchived:', currentlyArchived);

            var action = currentlyArchived ? 'unarchive' : 'archive';
            var formData = new FormData();
            formData.append('action', action);
            formData.append('id', notificationId);
            formData.append('type', type);

            fetch('../admin/inbox-messages', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(function(response) {
                console.log('Response status:', response.status);
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.status);
                }
                return response.text();
            })
            .then(function(text) {
                console.log('Response text:', text);
                try {
                    var data = JSON.parse(text);
                    console.log('Parsed response:', data);

                    if (data.success) {
                        console.log('Successfully ' + action + 'd');
                        notificationModal.classList.add('hidden');
                        loadNotifications(); // Reload untuk update status
                    } else {
                        alert('Failed: ' + (data.message || data.error || 'Unknown error'));
                    }
                } catch (e) {
                    console.error('JSON parse error:', e);
                    alert('Invalid response from server');
                }
            })
            .catch(function(error) {
                console.error('Error:', error);
                alert('Failed to ' + action + '. Please try again.');
            });
        }

        // PERUBAHAN: Update openNotificationModal untuk simpan currentNotification
        function openNotificationModal(notificationId, type) {
            console.log('openNotificationModal called with:', notificationId, type);

            var url = '../admin/inbox-messages?action=detail&id=' + notificationId + '&type=' + type;

            fetch(url, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json'
                }
            })
            .then(function(response) {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(function(text) {
                console.log('Detail response:', text);

                try {
                    var notification = JSON.parse(text);

                    if (notification.error) {
                        console.error('Error loading notification details:', notification.error);
                        showErrorMessage('Failed to load notification details');
                        return;
                    }

                    // Save current notification data
                    currentNotificationId = notificationId;
                    currentNotificationType = type;
                    currentNotification = notification; // Simpan object notification lengkap

                    console.log('Current notification saved:', currentNotification);

                    // Set modal icon
                    modalIcon.className = 'notification-type-icon mr-3';
                    if (type === 'register') {
                        modalIcon.classList.add('notification-type-register');
                        modalIcon.innerHTML = '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path></svg>';
                    } else {
                        modalIcon.classList.add('notification-type-cancel');
                        modalIcon.innerHTML = '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>';
                    }

                    // Set modal title and subtitle
                    modalTitle.textContent = notification.title || 'Notification Details';
                    modalSubtitle.textContent = notification.displayDate || '';

                    // Set modal content based on type
                    var contentHtml = '';
                    if (type === 'register') {
                        contentHtml = '<div>' +
                                '<div class="flex items-start mb-4">' +
                                '<img src="../profile_pictures/instructor/dummy.png" alt="Instructor" class="w-16 h-16 rounded-full object-cover border-2 border-blush mr-4">' +
                                '<div>' +
                                '<h4 class="font-medium text-espresso">' + (notification.instructorName || 'Unknown') + '</h4>' +
                                '<p class="text-sm text-espressoLighter">' + (notification.instructorEmail || 'No email') + '</p>' +
                                '<div class="mt-2 status-chip ' + getStatusClass(notification.status) + '">' +
                                (notification.status || 'unknown') +
                                '</div>' +
                                '</div>' +
                                '</div>' +
                                '<div class="space-y-3 text-sm">' +
                                '<div><span class="font-medium text-espressoLight">Phone:</span> ' + (notification.instructorPhone || 'Not provided') + '</div>' +
                                '<div><span class="font-medium text-espressoLight">NRIC:</span> ' + (notification.instructorNric || 'Not provided') + '</div>' +
                                '<div><span class="font-medium text-espressoLight">Registration Date:</span> ' + (notification.registerDate || 'Unknown') + '</div>' +
                                (notification.yearOfExperience ? '<div><span class="font-medium text-espressoLight">Experience:</span> ' + notification.yearOfExperience + ' years</div>' : '') +
                                (notification.address ? '<div><span class="font-medium text-espressoLight">Address:</span> ' + notification.address + '</div>' : '') +
                                '</div>' +
                                '<div class="mt-6 pt-4 border-t border-borderGray">' +
                                '<p class="text-sm text-espresso">This is a notification about a new instructor registration. Please review the instructor\'s details and take appropriate action in the instructor management section.</p>' +
                                '</div>' +
                                '</div>';
                    } else {
                        contentHtml = '<div>' +
                                '<div class="mb-4">' +
                                '<h4 class="font-medium text-espresso mb-2">' + (notification.className || 'Unknown Class') + '</h4>' +
                                '<div class="flex items-center space-x-4 text-sm">' +
                                '<div><span class="font-medium text-espressoLight">Instructor:</span> ' + (notification.instructorName || 'Unknown') + '</div>' +
                                '<div class="status-chip status-pending">' + (notification.status || 'pending') + '</div>' +
                                '</div>' +
                                '</div>' +
                                '<div class="space-y-3 text-sm mb-4">' +
                                (notification.classType ? '<div><span class="font-medium text-espressoLight">Class Type:</span> ' + notification.classType + '</div>' : '') +
                                (notification.classLevel ? '<div><span class="font-medium text-espressoLight">Level:</span> ' + notification.classLevel + '</div>' : '') +
                                (notification.classDate ? '<div><span class="font-medium text-espressoLight">Date:</span> ' + notification.classDate + '</div>' : '') +
                                (notification.classTime ? '<div><span class="font-medium text-espressoLight">Time:</span> ' + notification.classTime + '</div>' : '') +
                                '</div>' +
                                '<div class="mt-4 pt-4 border-t border-borderGray">' +
                                '<h5 class="font-medium text-espresso mb-2">Cancellation Reason:</h5>' +
                                '<div class="bg-softGray p-4 rounded-lg">' +
                                '<p class="text-sm text-espressoLighter">' + (notification.cancellationReason || 'No reason provided') + '</p>' +
                                '</div>' +
                                '<p class="text-sm text-espresso mt-4">This is a notification about a class cancellation. Please check the class schedule and make necessary arrangements in the class management section.</p>' +
                                '</div>' +
                                '</div>';
                    }

                    modalContent.innerHTML = contentHtml;
                    modalDate.textContent = 'Received ' + (notification.displayDate || '');

                    // PERUBAHAN: Update button text berdasarkan status
                    console.log('Notification isRead:', notification.isRead);
                    console.log('Notification archived:', notification.archived);

                    if (notification.isRead) {
                        markAsReadBtn.textContent = 'Mark as Unread';
                        markAsReadBtn.classList.remove('action-btn-mark');
                        markAsReadBtn.classList.add('action-btn-read');
                    } else {
                        markAsReadBtn.textContent = 'Mark as Read';
                        markAsReadBtn.classList.remove('action-btn-read');
                        markAsReadBtn.classList.add('action-btn-mark');
                    }

                    if (notification.archived) {
                        archiveBtn.textContent = 'Unarchive';
                    } else {
                        archiveBtn.textContent = 'Archive';
                    }

                    // Show modal
                    notificationModal.classList.remove('hidden');

                } catch (e) {
                    console.error('JSON parse error:', e);
                    showErrorMessage('Failed to load notification details');
                }
            })
            .catch(function(error) {
                console.error('Error:', error);
                showErrorMessage('Failed to load notification details');
            });
        }

        function getStatusClass(status) {
            if (status === 'pending') {
                return 'status-pending';
            } else if (status === 'approved') {
                return 'status-approved';
            } else if (status === 'rejected') {
                return 'status-rejected';
            } else {
                return 'status-pending';
            }
        }

        function renderNotifications() {
            notificationsList.innerHTML = '';

            if (filteredData.length === 0) {
                noNotifications.classList.remove('hidden');
                notificationsList.classList.add('hidden');
                pagination.classList.add('hidden');
                return;
            }

            noNotifications.classList.add('hidden');
            notificationsList.classList.remove('hidden');
            pagination.classList.remove('hidden');

            for (var i = 0; i < filteredData.length; i++) {
                var notification = filteredData[i];
                var item = document.createElement('div');

                var itemClass = 'notification-item p-4 ' + (!notification.isRead ? 'unread' : '');
                item.className = itemClass;
                item.setAttribute('data-id', notification.id);
                item.setAttribute('data-type', notification.type);

                item.addEventListener('click', function (e) {
                    var id = this.getAttribute('data-id');
                    var type = this.getAttribute('data-type');
                    openNotificationModal(id, type);
                });

                // Icon based on type
                var icon = '';
                if (notification.type === 'register') {
                    icon = '<div class="notification-type-icon notification-type-register">' +
                            '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path>' +
                            '</svg></div>';
                } else {
                    icon = '<div class="notification-type-icon notification-type-cancel">' +
                            '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                            '</svg></div>';
                }

                // Type tag
                var typeTag = '';
                if (notification.type === 'register') {
                    typeTag = '<span class="notification-tag tag-register ml-2">Instructor Registration</span>';
                } else {
                    typeTag = '<span class="notification-tag tag-cancel ml-2">Instructor Class Cancellation Alert</span>';
                }

                // Status chip
                var statusChip = '';
                var statusClass = getStatusClass(notification.status);
                statusChip = '<span class="' + statusClass + '">' + notification.status + '</span>';

                // Content based on type
                var content = '';
                if (notification.type === 'register') {
                    content =
                            '<div class="flex-1 min-w-0">' +
                            '<div class="flex items-center mb-1">' +
                            '<h3 class="font-semibold text-espresso truncate">' + notification.instructorName + '</h3>' +
                            typeTag +
                            '</div>' +
                            '<p class="text-sm text-espressoLighter mb-2">' + notification.instructorEmail + '</p>' +
                            '<div class="flex items-center space-x-3">' +
                            statusChip +
                            '<span class="text-xs text-espressoLighter">Registered on ' + notification.registerDate + '</span>' +
                            '</div>' +
                            '</div>';
                } else {
                    content =
                            '<div class="flex-1 min-w-0">' +
                            '<div class="flex items-center mb-1">' +
                            '<h3 class="font-semibold text-espresso truncate">' + (notification.className || 'Class') + ' cancelled</h3>' +
                            typeTag +
                            '</div>' +
                            '<p class="text-sm text-espressoLighter mb-2">Instructor: ' + notification.instructorName + ' • Date: ' + (notification.classDate || 'Unknown') + '</p>' +
                            '<div class="flex items-center space-x-3">' +
                            statusChip +
                            '<span class="text-xs text-espressoLighter">' + notification.displayDate + '</span>' +
                            '</div>' +
                            '</div>';
                }

                // Read status indicator
                var readIndicator = '';
                if (notification.isRead) {
                    readIndicator = '<div class="w-2 h-2 rounded-full bg-espressoLighter"></div>';
                } else {
                    readIndicator = '<div class="w-2 h-2 rounded-full bg-teal"></div>';
                }

                // Archive indicator
                var archiveIndicator = '';
                if (notification.archived) {
                    archiveIndicator = '<svg class="w-4 h-4 text-espressoLighter ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4"></path></svg>';
                }

                item.innerHTML =
                        '<div class="flex items-start justify-between">' +
                        '<div class="flex items-start flex-1 min-w-0">' +
                        icon +
                        '<div class="flex-1 min-w-0">' +
                        content +
                        '</div>' +
                        '</div>' +
                        '<div class="ml-4 flex flex-col items-end">' +
                        '<div class="mb-2 flex items-center">' +
                        readIndicator +
                        archiveIndicator +
                        '</div>' +
                        '<span class="text-xs text-espressoLighter text-right">' + notification.displayDate + '</span>' +
                        '</div>' +
                        '</div>';

                notificationsList.appendChild(item);
            }
        }

        function updatePaginationInfo(totalCount, totalPages) {
            var startIndex = (currentPage - 1) * itemsPerPage + 1;
            var endIndex = Math.min(currentPage * itemsPerPage, totalCount);

            startRowSpan.textContent = startIndex;
            endRowSpan.textContent = endIndex;
            totalRowsSpan.textContent = totalCount;

            prevPageBtn.disabled = currentPage === 1;
            nextPageBtn.disabled = currentPage === totalPages;

            pageNumbers.innerHTML = '';
            var maxVisiblePages = 5;
            var startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
            var endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);

            if (endPage - startPage + 1 < maxVisiblePages) {
                startPage = Math.max(1, endPage - maxVisiblePages + 1);
            }

            for (var i = startPage; i <= endPage; i++) {
                var pageBtn = document.createElement('button');
                pageBtn.textContent = i;
                pageBtn.className = 'px-3 py-1.5 rounded text-sm min-w-[36px] transition-colors ' +
                        (i === currentPage ? 'bg-dusty text-whitePure' : 'border border-borderGray text-espressoLighter hover:bg-softGray');
                pageBtn.addEventListener('click', (function (page) {
                    return function () {
                        currentPage = page;
                        loadNotifications();
                    };
                })(i));
                pageNumbers.appendChild(pageBtn);
            }
        }

        function showErrorMessage(message) {
            // Create error message element
            var errorDiv = document.createElement('div');
            errorDiv.className = 'bg-dangerBg border border-dangerBorder text-dangerText px-4 py-3 rounded mb-4';
            errorDiv.innerHTML = '<strong>Error:</strong> ' + message;

            // Insert at the top of the main content
            var mainContent = document.querySelector('main > div');
            mainContent.insertBefore(errorDiv, mainContent.firstChild);

            // Remove after 5 seconds
            setTimeout(function() {
                errorDiv.remove();
            }, 5000);
        }

        document.addEventListener('DOMContentLoaded', init);
    </script>

    </body>
</html>