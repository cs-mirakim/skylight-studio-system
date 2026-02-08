<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>

<%
    // Check if user is logged in
    if (!SessionUtil.isLoggedIn(session)) {
        response.sendRedirect("../general/login.jsp");
        return;
    }

    // Get user role from session
    String userRole = SessionUtil.getUserRole(session);
    String userName = SessionUtil.getUserName(session);

    // Determine display role text
    String displayRole = "User";
    if ("admin".equals(userRole)) {
        displayRole = "Admin";
    } else if ("instructor".equals(userRole)) {
        displayRole = "Instructor";
    }

    // Get initial inbox count (will be updated by AJAX)
    int sidebarInboxCount = 0;
%>

<div id="sidebar-overlay" class="fixed inset-0 bg-espresso/40 backdrop-blur-sm hidden z-40" aria-hidden="true"></div>

<aside id="sidebar"
       class="fixed left-0 top-0 h-full w-64 bg-whitePure text-espresso transform -translate-x-full transition-transform duration-300 z-50 shadow-2xl flex flex-col border-r border-petal"
       aria-hidden="true" aria-label="Sidebar"
       data-user-role="<%= userRole%>"
       data-inbox-count="<%= sidebarInboxCount%>">

    <div class="p-6 border-b border-petal flex-shrink-0">
        <div class="flex items-center justify-between">
            <div class="text-xl font-bold tracking-tight text-dusty">Skylight Studio</div>
            <button id="sidebarClose" class="p-2 rounded-full hover:bg-petal transition-colors text-espresso/40 hover:text-espresso">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
            </button>
        </div>
    </div>

    <nav id="sidebar-menu" class="flex-1 overflow-y-auto custom-scrollbar" aria-label="Sidebar navigation">
        <!-- Menu akan di-render oleh sidebar.js -->
    </nav>

    <div class="p-4 border-t border-petal flex-shrink-0 bg-cloud/50">
        <button id="sidebar-logout"
                class="w-full inline-flex items-center justify-center px-4 py-3 rounded-xl bg-dusty text-whitePure font-bold hover:bg-dustyHover transition-all shadow-lg shadow-dusty/20 active:scale-[0.98]"
                title="Logout">
            Logout
        </button>
    </div>
</aside>

<!-- LOGOUT MODAL -->
<div id="logoutModal"
     class="hidden fixed inset-0 bg-espresso/50 backdrop-blur-sm flex items-center justify-center p-4 z-[60]">
    <div class="bg-whitePure p-6 rounded-xl shadow-lg shadow-blush/30 w-full max-w-sm border border-blush">
        <h2 class="text-xl font-semibold mb-4 text-center text-espresso">
            Confirm Logout
        </h2>

        <hr class="border-petal mb-4">

            <div class="mb-6">
                <p class="text-sm text-espresso/70 text-center mb-3">
                    Are you sure you want to logout from Skylight Studio Management System?
                </p>
                <div class="flex items-center gap-2 p-3 rounded-lg bg-cloud/50 border border-petal">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-dusty flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                    </svg>
                    <p class="text-xs text-espresso/70">
                        Your session will be terminated and you'll need to login again.
                    </p>
                </div>
            </div>

            <div class="flex flex-col gap-2">
                <form id="logoutForm" action="<%= request.getContextPath()%>/authenticate" method="GET" style="display: none;">
                    <input type="hidden" name="action" value="logout">
                </form>

                <button onclick="performLogout()"
                        class="w-full bg-dusty hover:bg-dustyHover text-whitePure p-3 rounded-lg font-medium transition-colors">
                    Yes, Logout
                </button>

                <button onclick="closeLogoutModal()"
                        class="w-full bg-cloud hover:bg-blush text-espresso p-3 rounded-lg font-medium transition-colors border border-blush">
                    Cancel
                </button>
            </div>
    </div>
</div>

<style>
    .custom-scrollbar::-webkit-scrollbar { width: 4px; }
    .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
    .custom-scrollbar::-webkit-scrollbar-thumb {
        background: #EFE1E1;
        border-radius: 10px;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #B36D6D; }
</style>

<script>
    // Logout functions
    function openLogoutModal() {
        document.getElementById('logoutModal').classList.remove('hidden');
    }

    function closeLogoutModal() {
        document.getElementById('logoutModal').classList.add('hidden');
    }

    function performLogout() {
        document.getElementById('logoutForm').submit();
    }

    // Event listeners for logout modal
    document.addEventListener('DOMContentLoaded', function () {
        var logoutBtn = document.getElementById('sidebar-logout');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', openLogoutModal);
        }

        // Close modal with Escape key
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                closeLogoutModal();
            }
        });

        // Close modal when clicking outside
        var logoutModal = document.getElementById('logoutModal');
        if (logoutModal) {
            logoutModal.addEventListener('click', function (e) {
                if (e.target.id === 'logoutModal') {
                    closeLogoutModal();
                }
            });
        }
    });
</script>
