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
        <title>Review Registration Page</title>

        <!-- Font Inter + Lora -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <!-- Tailwind CDN -->
        <script src="https://cdn.tailwindcss.com"></script>

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
                            successText: '#1E3A1E',
                            teal: '#6D9B9B',
                            tealSoft: '#A3C1D6',
                            tealHover: '#557878',
                            successBg: '#A5D6A7',
                            successTextDark: '#1B5E20',
                            warningBg: '#FFCC80',
                            warningText: '#E65100',
                            dangerBg: '#EF9A9A',
                            dangerText: '#B71C1C',
                            infoBg: '#A3C1D6',
                            infoText: '#2C5555',
                            chipRose: '#FCE4EC',
                            chipSand: '#D9C5B2',
                            chipTeal: '#6D9B9B',
                            certBlue: '#4F8A8B',
                            certBlueHover: '#3D6B6C',
                            filterActive: '#4F8A8B',
                            filterHover: '#3D6B6C'
                        }
                    }
                }
            }
        </script>
        <style>
            .modal-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0, 0, 0, 0.5);
                backdrop-filter: blur(5px);
                z-index: 1000;
                align-items: center;
                justify-content: center;
            }

            .modal-content {
                background-color: white;
                border-radius: 0.75rem;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
                max-width: 800px;
                width: 90%;
                max-height: 90vh;
                overflow-y: auto;
            }

            .status-pending {
                background-color: #FFCC80;
                color: #E65100;
            }

            .status-approved {
                background-color: #A5D6A7;
                color: #1B5E20;
            }

            .status-rejected {
                background-color: #EF9A9A;
                color: #B71C1C;
            }

            .pagination-btn {
                transition: all 0.2s ease;
            }

            .pagination-btn:hover:not(.disabled) {
                background-color: #F2D1D1;
            }

            .table-row {
                transition: background-color 0.2s ease;
                border-bottom: 2px solid #EFE1E1;
            }

            .table-row:hover {
                background-color: #FDF8F8;
            }

            .action-modal {
                max-width: 500px;
            }

            .badge-experience {
                background-color: #A3C1D6;
                color: #2C5555;
            }

            .cert-badge {
                background-color: #4F8A8B;
                color: white;
            }

            .cert-badge:hover {
                background-color: #3D6B6C;
            }

            .textarea-fixed {
                resize: none;
                overflow-y: auto;
                min-height: 100px;
                max-height: 200px;
            }

            /* Custom class untuk button yang seragam */
            .uniform-button {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 0.5rem;
                padding: 0.625rem 1rem; /* py-2.5 px-4 */
                border-radius: 0.5rem; /* rounded-lg */
                font-size: 0.875rem; /* text-sm */
                font-weight: 500; /* font-medium */
                transition: all 0.2s ease;
                width: 100%;
                min-height: 2.75rem;
                border: 1px solid transparent;
            }

            /* Untuk button dalam td (table cell) */
            td .uniform-button {
                min-width: 140px;
            }

            /* Status filter pill styles */
            .filter-pill {
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                padding: 0.5rem 1rem;
                border-radius: 9999px;
                font-size: 0.875rem;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.2s ease;
                border: 2px solid transparent;
            }

            .filter-pill.active {
                background-color: #4F8A8B;
                color: white;
                border-color: #4F8A8B;
            }

            .filter-pill.inactive {
                background-color: white;
                color: #3D3434;
                border: 2px solid #F2D1D1;
            }

            .filter-pill.inactive:hover {
                background-color: #FDF8F8;
                border-color: #E8BEBE;
            }

            .filter-count {
                font-size: 0.75rem;
                background-color: rgba(255, 255, 255, 0.2);
                padding: 0.125rem 0.5rem;
                border-radius: 9999px;
                margin-left: 0.25rem;
            }

            .filter-pill.inactive .filter-count {
                background-color: #F2D1D1;
                color: #3D3434;
            }

            .loading-spinner {
                display: inline-block;
                width: 20px;
                height: 20px;
                border: 3px solid rgba(0,0,0,.1);
                border-radius: 50%;
                border-top-color: #4F8A8B;
                animation: spin 1s ease-in-out infinite;
            }

            @keyframes spin {
                to { transform: rotate(360deg); }
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">

            <div class="w-full bg-whitePure py-6 px-6 md:px-8 rounded-xl shadow-sm border border-blush flex-1 flex flex-col" style="max-width:1500px">

                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                        <div>
                            <h2 class="text-xl font-semibold mb-1 text-espresso">
                                Instructor Registration Review
                            </h2>
                            <p class="text-sm text-espresso/60">
                                Manage and review all instructor registration applications
                            </p>
                        </div>
                        <div class="flex items-center gap-2">
                            <div class="text-sm bg-cloud px-3 py-1.5 rounded-lg border border-blush">
                                <span class="text-espresso/60">Total:</span>
                                <span id="totalApplications" class="font-medium text-espresso ml-1">0</span>
                            </div>
                            <div class="text-sm bg-cloud px-3 py-1.5 rounded-lg border border-blush">
                                <span class="text-espresso/60">Pending:</span>
                                <span id="pendingApplications" class="font-medium text-warningText ml-1">0</span>
                            </div>
                            <div class="text-sm bg-cloud px-3 py-1.5 rounded-lg border border-blush">
                                <span class="text-espresso/60">Approved:</span>
                                <span id="approvedApplications" class="font-medium text-successTextDark ml-1">0</span>
                            </div>
                            <div class="text-sm bg-cloud px-3 py-1.5 rounded-lg border border-blush">
                                <span class="text-espresso/60">Rejected:</span>
                                <span id="rejectedApplications" class="font-medium text-dangerText ml-1">0</span>
                            </div>
                            <button onclick="loadRegistrations(true)" class="ml-2 bg-dusty hover:bg-dustyHover text-whitePure px-4 py-2 rounded-lg text-sm font-medium transition-colors duration-200 flex items-center gap-2">
                                <svg id="refreshIcon" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                                </svg>
                                <span>Refresh</span>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Enhanced Filters Section with Status Tabs -->
                <div class="mb-6">
                    <!-- Status Filter Tabs -->
                    <div class="mb-4">
                        <div class="flex flex-wrap items-center gap-2 mb-3">
                            <span class="text-sm font-medium text-espresso">Status:</span>
                            <div class="flex flex-wrap gap-2">
                                <button onclick="filterByStatus('all')" id="filter-all" class="filter-pill active">
                                    All
                                    <span id="count-all" class="filter-count">0</span>
                                </button>
                                <button onclick="filterByStatus('pending')" id="filter-pending" class="filter-pill inactive">
                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"></path>
                                    </svg>
                                    Pending
                                    <span id="count-pending" class="filter-count">0</span>
                                </button>
                                <button onclick="filterByStatus('approved')" id="filter-approved" class="filter-pill inactive">
                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                                    </svg>
                                    Approved
                                    <span id="count-approved" class="filter-count">0</span>
                                </button>
                                <button onclick="filterByStatus('rejected')" id="filter-rejected" class="filter-pill inactive">
                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                                    <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path>
                                    </svg>
                                    Rejected
                                    <span id="count-rejected" class="filter-count">0</span>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Additional Filters -->
                    <div class="flex flex-wrap items-center gap-3">
                        <span class="text-sm font-medium text-espresso">Additional Filters:</span>

                        <!-- Date Filter -->
                        <div class="relative">
                            <select id="dateFilter" class="appearance-none bg-whitePure border border-blush rounded-lg px-4 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-dusty focus:border-dusty cursor-pointer">
                                <option value="newest">Newest First</option>
                                <option value="oldest">Oldest First</option>
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-espresso/60">
                                <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                                <path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/>
                                </svg>
                            </div>
                        </div>

                        <!-- Experience Filter -->
                        <div class="relative">
                            <select id="experienceFilter" class="appearance-none bg-whitePure border border-blush rounded-lg px-4 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-dusty focus:border-dusty cursor-pointer">
                                <option value="all">All Experience</option>
                                <option value="0-2">0-2 Years</option>
                                <option value="3-5">3-5 Years</option>
                                <option value="6-10">6-10 Years</option>
                                <option value="10+">10+ Years</option>
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-espresso/60">
                                <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                                <path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/>
                                </svg>
                            </div>
                        </div>

                        <!-- Search by Name -->
                        <div class="relative">
                            <div class="relative">
                                <input type="text" id="searchName" placeholder="Search by name..." class="bg-whitePure border border-blush rounded-lg px-4 py-2 pl-10 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-dusty focus:border-dusty w-64">
                                <svg class="absolute left-3 top-2.5 h-5 w-5 text-espresso/40" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                                </svg>
                            </div>
                        </div>

                        <!-- Apply All Filters Button -->
                        <button onclick="applyAllFilters()" class="bg-dusty hover:bg-dustyHover text-whitePure px-4 py-2 rounded-lg text-sm font-medium transition-colors duration-200">
                            Apply Filters
                        </button>

                        <!-- Reset All Filters Button -->
                        <button onclick="resetAllFilters()" class="bg-petal hover:bg-blushHover text-espresso px-4 py-2 rounded-lg text-sm font-medium transition-colors duration-200">
                            Reset All
                        </button>
                    </div>
                </div>

                <!-- Current Filters Display -->
                <div id="activeFiltersDisplay" class="mb-4 hidden">
                    <div class="flex flex-wrap items-center gap-2">
                        <span class="text-sm font-medium text-espresso">Active Filters:</span>
                        <div id="activeFiltersList" class="flex flex-wrap gap-2">
                            <!-- Active filters will be displayed here -->
                        </div>
                    </div>
                </div>

                <!-- Loading State -->
                <div id="loadingState" class="text-center py-12">
                    <div class="loading-spinner mx-auto mb-4"></div>
                    <p class="text-espresso/50">Loading registration data...</p>
                </div>

                <!-- Table Section -->
                <div class="flex-1 overflow-x-auto" id="tableContainer" style="display: none;">
                    <table class="w-full">
                        <thead>
                            <tr class="border-b-2 border-espresso/20">
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Instructor</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Contact Info</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Experience</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Registration Date</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Status</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">View Details</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Certification</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="registrationTable">
                            <!-- Table rows will be loaded here by JavaScript -->
                        </tbody>
                    </table>

                    <!-- No Results State -->
                    <div id="noResultsState" class="text-center py-12 hidden">
                        <svg class="mx-auto h-16 w-16 text-espresso/20" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        <p class="mt-4 text-espresso/50">No registrations found matching your filters.</p>
                        <button onclick="resetAllFilters()" class="mt-3 bg-dusty hover:bg-dustyHover text-whitePure px-4 py-2 rounded-lg text-sm font-medium transition-colors duration-200">
                            Reset Filters
                        </button>
                    </div>
                </div>

                <!-- Pagination -->
                <div class="mt-8 pt-6 border-t border-espresso/10" id="paginationContainer" style="display: none;">
                    <div class="flex items-center justify-between">
                        <div class="text-sm text-espresso/60">
                            Showing <span id="currentRange">0-0</span> of <span id="totalRegistrations">0</span> registrations
                        </div>
                        <div class="flex items-center space-x-2">
                            <button id="prevPage" onclick="changePage(currentPage - 1)" class="pagination-btn p-2 rounded-lg border border-blush text-espresso/60 hover:text-espresso disabled:opacity-50 disabled:cursor-not-allowed" disabled>
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                                </svg>
                            </button>
                            <div class="flex items-center space-x-1" id="pageNumbers">
                                <!-- Page numbers will be inserted here by JavaScript -->
                            </div>
                            <button id="nextPage" onclick="changePage(currentPage + 1)" class="pagination-btn p-2 rounded-lg border border-blush text-espresso/60 hover:text-espresso disabled:opacity-50 disabled:cursor-not-allowed" disabled>
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>

            </div>

        </main>

        <!-- Details Modal Overlay -->
        <div id="modalOverlay" class="modal-overlay" onclick="closeModal()">
            <div class="modal-content" onclick="stopPropagation(event)">
                <!-- Modal content will be inserted here by JavaScript -->
            </div>
        </div>

        <!-- PDF Viewer Modal -->
        <div id="pdfModalOverlay" class="modal-overlay" onclick="closePdfModal()">
            <div class="modal-content" style="max-width: 90%; height: 90vh;" onclick="stopPropagation(event)">
                <div class="p-4 h-full flex flex-col">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-semibold text-espresso">Certificate Preview</h3>
                        <button onclick="closePdfModal()" class="text-espresso/60 hover:text-espresso">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </button>
                    </div>
                    <div class="flex-1 border border-blush rounded-lg bg-cloud overflow-hidden">
                        <iframe id="pdfViewer" class="w-full h-full" frameborder="0"></iframe>
                    </div>
                </div>
            </div>
        </div>

        <!-- Approve/Reject Confirmation Modal -->
        <div id="actionModalOverlay" class="modal-overlay" onclick="closeActionModal()">
            <div class="modal-content action-modal" onclick="stopPropagation(event)">
                <!-- Action modal content will be inserted here by JavaScript -->
            </div>
        </div>

        <jsp:include page="../util/footer.jsp" />
        <jsp:include page="../util/sidebar.jsp" />

        <script src="../util/sidebar.js"></script>

        <script>
                // Global variables
                var currentPage = 1;
                var registrationsPerPage = 5;
                var filteredRegistrations = [];
                var allRegistrations = [];
                var currentPdfUrl = null;
                var currentActionRegId = null;
                var currentActionType = null;
                var currentDetailsRegId = null;

                // Filter state
                var currentStatusFilter = 'all';
                var currentDateFilter = 'newest';
                var currentExperienceFilter = 'all';
                var currentSearchName = '';

                // DOM elements
                var registrationTable = document.getElementById('registrationTable');
                var noResultsState = document.getElementById('noResultsState');
                var loadingState = document.getElementById('loadingState');
                var tableContainer = document.getElementById('tableContainer');
                var paginationContainer = document.getElementById('paginationContainer');
                var totalApplications = document.getElementById('totalApplications');
                var pendingApplications = document.getElementById('pendingApplications');
                var activeFiltersDisplay = document.getElementById('activeFiltersDisplay');
                var activeFiltersList = document.getElementById('activeFiltersList');
                var refreshIcon = document.getElementById('refreshIcon');

                // Initialize page
                document.addEventListener('DOMContentLoaded', function () {
                    // Load registrations from server
                    loadRegistrations(false);

                    // Initialize search input event listener
                    document.getElementById('searchName').addEventListener('keyup', function (event) {
                        if (event.key === 'Enter') {
                            applyAllFilters();
                        }
                    });
                });

                // Load registrations from server
                function loadRegistrations(showLoading) {
                    if (showLoading) {
                        loadingState.style.display = 'block';
                        tableContainer.style.display = 'none';
                        paginationContainer.style.display = 'none';
                        refreshIcon.classList.add('loading-spinner');
                    }

                    var xhr = new XMLHttpRequest();
                    xhr.open('GET', '../register?action=getRegistrations', true);
                    xhr.setRequestHeader('Content-Type', 'application/json');

                    xhr.onreadystatechange = function () {
                        if (xhr.readyState === 4) {
                            refreshIcon.classList.remove('loading-spinner');

                            if (xhr.status === 200) {
                                try {
                                    var response = JSON.parse(xhr.responseText);
                                    if (response.success) {
                                        allRegistrations = response.data;

                                        // Initialize with all registrations
                                        filteredRegistrations = allRegistrations.slice();

                                        // Update statistics
                                        updateStatistics();
                                        updateFilterCounts();

                                        // Display data
                                        currentPage = 1;
                                        updateDisplay();

                                        // Show table and pagination
                                        loadingState.style.display = 'none';
                                        tableContainer.style.display = 'block';
                                        paginationContainer.style.display = 'block';
                                    } else {
                                        showError('Failed to load data: ' + response.message);
                                    }
                                } catch (e) {
                                    showError('Error parsing response: ' + e.message);
                                }
                            } else if (xhr.status === 401) {
                                window.location.href = '../general/login.jsp?error=admin_access_required';
                            } else {
                                showError('Server error: ' + xhr.status);
                            }
                        }
                    };

                    xhr.send();
                }

                // Show error message
                function showError(message) {
                    loadingState.innerHTML = '<div class="text-center py-12">' +
                            '<svg class="mx-auto h-16 w-16 text-dangerText" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>' +
                            '</svg>' +
                            '<p class="mt-4 text-dangerText">' + message + '</p>' +
                            '<button onclick="loadRegistrations(true)" class="mt-3 bg-dusty hover:bg-dustyHover text-whitePure px-4 py-2 rounded-lg text-sm font-medium transition-colors duration-200">' +
                            'Try Again' +
                            '</button>' +
                            '</div>';
                }

                // Update statistics function
                function updateStatistics() {
                    var total = allRegistrations.length;
                    var pending = allRegistrations.filter(function (reg) {
                        return reg.status === 'pending';
                    }).length;
                    var approved = allRegistrations.filter(function (reg) {
                        return reg.status === 'approved';
                    }).length;
                    var rejected = allRegistrations.filter(function (reg) {
                        return reg.status === 'rejected';
                    }).length;

                    totalApplications.textContent = total;
                    pendingApplications.textContent = pending;
                    document.getElementById('approvedApplications').textContent = approved;
                    document.getElementById('rejectedApplications').textContent = rejected;
                }

                // Update filter counts function
                function updateFilterCounts() {
                    var allCount = allRegistrations.length;
                    var pendingCount = allRegistrations.filter(function (reg) {
                        return reg.status === 'pending';
                    }).length;
                    var approvedCount = allRegistrations.filter(function (reg) {
                        return reg.status === 'approved';
                    }).length;
                    var rejectedCount = allRegistrations.filter(function (reg) {
                        return reg.status === 'rejected';
                    }).length;

                    document.getElementById('count-all').textContent = allCount;
                    document.getElementById('count-pending').textContent = pendingCount;
                    document.getElementById('count-approved').textContent = approvedCount;
                    document.getElementById('count-rejected').textContent = rejectedCount;
                }

                // Stop propagation function
                function stopPropagation(event) {
                    event.stopPropagation();
                }

                // Filter by status function
                function filterByStatus(status) {
                    currentStatusFilter = status;

                    // Update active status filter pills
                    document.querySelectorAll('.filter-pill').forEach(function (pill) {
                        pill.classList.remove('active');
                        pill.classList.add('inactive');
                    });

                    document.getElementById('filter-' + status).classList.remove('inactive');
                    document.getElementById('filter-' + status).classList.add('active');

                    // Apply all filters
                    applyAllFilters();
                }

                // Apply all filters function
                function applyAllFilters() {
                    currentDateFilter = document.getElementById('dateFilter').value;
                    currentExperienceFilter = document.getElementById('experienceFilter').value;
                    currentSearchName = document.getElementById('searchName').value.toLowerCase().trim();

                    filteredRegistrations = allRegistrations.filter(function (reg) {
                        // Status filter
                        if (currentStatusFilter !== 'all' && reg.status !== currentStatusFilter) {
                            return false;
                        }

                        // Experience filter
                        if (currentExperienceFilter !== 'all') {
                            var exp = reg.yearOfExperience;
                            switch (currentExperienceFilter) {
                                case '0-2':
                                    if (exp > 2)
                                        return false;
                                    break;
                                case '3-5':
                                    if (exp < 3 || exp > 5)
                                        return false;
                                    break;
                                case '6-10':
                                    if (exp < 6 || exp > 10)
                                        return false;
                                    break;
                                case '10+':
                                    if (exp < 10)
                                        return false;
                                    break;
                            }
                        }

                        // Name search filter
                        if (currentSearchName !== '') {
                            if (!reg.name.toLowerCase().includes(currentSearchName)) {
                                return false;
                            }
                        }

                        return true;
                    });

                    // Date sorting
                    filteredRegistrations.sort(function (a, b) {
                        var dateA = new Date(a.registerDate);
                        var dateB = new Date(b.registerDate);

                        if (currentDateFilter === 'newest') {
                            return dateB - dateA;
                        } else {
                            return dateA - dateB;
                        }
                    });

                    // Update active filters display
                    updateActiveFiltersDisplay();

                    currentPage = 1;
                    updateDisplay();
                }

                // Update active filters display
                function updateActiveFiltersDisplay() {
                    activeFiltersList.innerHTML = '';

                    var hasActiveFilters = false;

                    // Status filter
                    if (currentStatusFilter !== 'all') {
                        hasActiveFilters = true;
                        var statusText = currentStatusFilter.charAt(0).toUpperCase() + currentStatusFilter.slice(1);
                        activeFiltersList.innerHTML += `
                            <div class="flex items-center gap-1 bg-cloud border border-blush rounded-full px-3 py-1 text-xs">
                                <span class="text-espresso/60">Status:</span>
                                <span class="font-medium text-espresso ml-1">${statusText}</span>
                                <button onclick="removeStatusFilter()" class="ml-1 text-espresso/40 hover:text-espresso">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                                    </svg>
                                </button>
                            </div>
                        `;
                    }

                    // Experience filter
                    if (currentExperienceFilter !== 'all') {
                        hasActiveFilters = true;
                        var expText = currentExperienceFilter;
                        activeFiltersList.innerHTML += `
                            <div class="flex items-center gap-1 bg-cloud border border-blush rounded-full px-3 py-1 text-xs">
                                <span class="text-espresso/60">Experience:</span>
                                <span class="font-medium text-espresso ml-1">${expText}</span>
                                <button onclick="removeExperienceFilter()" class="ml-1 text-espresso/40 hover:text-espresso">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                                    </svg>
                                </button>
                            </div>
                        `;
                    }

                    // Search filter
                    if (currentSearchName !== '') {
                        hasActiveFilters = true;
                        activeFiltersList.innerHTML += `
                            <div class="flex items-center gap-1 bg-cloud border border-blush rounded-full px-3 py-1 text-xs">
                                <span class="text-espresso/60">Search:</span>
                                <span class="font-medium text-espresso ml-1">"${currentSearchName}"</span>
                                <button onclick="removeSearchFilter()" class="ml-1 text-espresso/40 hover:text-espresso">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                                    </svg>
                                </button>
                            </div>
                        `;
                    }

                    // Show/hide active filters display
                    if (hasActiveFilters) {
                        activeFiltersDisplay.classList.remove('hidden');
                    } else {
                        activeFiltersDisplay.classList.add('hidden');
                    }
                }

                // Remove status filter
                function removeStatusFilter() {
                    filterByStatus('all');
                }

                // Remove experience filter
                function removeExperienceFilter() {
                    document.getElementById('experienceFilter').value = 'all';
                    currentExperienceFilter = 'all';
                    applyAllFilters();
                }

                // Remove search filter
                function removeSearchFilter() {
                    document.getElementById('searchName').value = '';
                    currentSearchName = '';
                    applyAllFilters();
                }

                // Reset all filters function
                function resetAllFilters() {
                    document.getElementById('dateFilter').value = 'newest';
                    document.getElementById('experienceFilter').value = 'all';
                    document.getElementById('searchName').value = '';

                    filterByStatus('all');
                }

                // Update display function
                function updateDisplay() {
                    // Clear current table
                    registrationTable.innerHTML = '';
                    noResultsState.classList.add('hidden');

                    if (filteredRegistrations.length === 0) {
                        noResultsState.classList.remove('hidden');
                        updatePagination();
                        return;
                    }

                    // Calculate pagination
                    var startIndex = (currentPage - 1) * registrationsPerPage;
                    var endIndex = Math.min(startIndex + registrationsPerPage, filteredRegistrations.length);
                    var currentRegistrations = filteredRegistrations.slice(startIndex, endIndex);

                    // Add registrations to table
                    for (var i = 0; i < currentRegistrations.length; i++) {
                        var reg = currentRegistrations[i];
                        registrationTable.appendChild(createTableRow(reg));
                    }

                    updatePagination();
                }

                // Create table row function
                function createTableRow(reg) {
                    var row = document.createElement('tr');
                    row.className = 'table-row';

                    var statusClass = 'status-' + reg.status;
                    var statusText = reg.status.charAt(0).toUpperCase() + reg.status.slice(1);
                    var expText = reg.yearOfExperience + ' year' + (reg.yearOfExperience !== 1 ? 's' : '');

                    // Handle file paths - add ../ prefix
                    var profileImagePath = reg.profileImagePath ? ('../' + reg.profileImagePath) : '../profile_pictures/instructor/dummy.png';
                    var certificationPath = reg.certification ? ('../' + reg.certification) : '../certifications/instructor/dummy.pdf';

                    row.innerHTML =
                            '<td class="py-4 px-4">' +
                            '<div class="flex items-center gap-3">' +
                            '<div class="w-10 h-10 rounded-full overflow-hidden bg-petal flex-shrink-0">' +
                            '<img src="' + profileImagePath + '" alt="Profile" class="w-full h-full object-cover" onerror="this.src=\'../profile_pictures/instructor/dummy.png\'">' +
                            '</div>' +
                            '<div>' +
                            '<div class="font-medium text-espresso">' + reg.name + '</div>' +
                            '<div class="text-xs text-espresso/60">IC: ' + reg.nric + '</div>' +
                            '</div>' +
                            '</div>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<div class="text-sm">' + reg.email + '</div>' +
                            '<div class="text-xs text-espresso/60">' + reg.phone + '</div>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<span class="px-3 py-1 rounded-full text-xs font-medium badge-experience">' + expText + '</span>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<div class="text-sm">' + formatDate(reg.registerDate) + '</div>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<span class="px-3 py-1 rounded-full text-xs font-medium ' + statusClass + '">' + statusText + '</span>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<button onclick="viewDetails(' + reg.id + ')" class="uniform-button bg-whitePure border border-teal text-teal hover:bg-tealSoft">' +
                            '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>' +
                            '</svg>' +
                            '<span>View Details</span>' +
                            '</button>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<button onclick="viewPdf(\'' + certificationPath + '\')" class="uniform-button cert-badge hover:certBlueHover">' +
                            '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>' +
                            '</svg>' +
                            '<span>View Certificate</span>' +
                            '</button>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<div class="flex flex-col gap-2">' +
                            (reg.status === 'pending' ?
                                    '<button onclick="showApproveModal(' + reg.id + ', ' + reg.registerID + ')" class="uniform-button bg-successBg hover:bg-successBg/80 text-successTextDark">' +
                                    '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                                    '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>' +
                                    '</svg>' +
                                    '<span>Approve</span>' +
                                    '</button>' +
                                    '<button onclick="showRejectModal(' + reg.id + ', ' + reg.registerID + ')" class="uniform-button bg-dangerBg hover:bg-dangerBg/80 text-dangerText">' +
                                    '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                                    '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                                    '</svg>' +
                                    '<span>Reject</span>' +
                                    '</button>' :
                                    '<span class="text-xs text-espresso/40 italic text-center py-2">Action completed</span>') +
                            '</div>' +
                            '</td>';

                    return row;
                }

                // Update pagination function
                function updatePagination() {
                    var totalPages = Math.ceil(filteredRegistrations.length / registrationsPerPage);
                    var startIndex = (currentPage - 1) * registrationsPerPage + 1;
                    var endIndex = Math.min(currentPage * registrationsPerPage, filteredRegistrations.length);

                    // Update range text
                    document.getElementById('currentRange').textContent = startIndex + '-' + endIndex;
                    document.getElementById('totalRegistrations').textContent = filteredRegistrations.length;

                    // Update pagination buttons
                    var prevBtn = document.getElementById('prevPage');
                    var nextBtn = document.getElementById('nextPage');

                    prevBtn.disabled = currentPage === 1;
                    nextBtn.disabled = currentPage === totalPages;

                    // Update page numbers
                    var pageNumbersContainer = document.getElementById('pageNumbers');
                    pageNumbersContainer.innerHTML = '';

                    // Always show first page
                    addPageNumber(pageNumbersContainer, 1);

                    // Calculate range of pages to show
                    var startPage = Math.max(2, currentPage - 1);
                    var endPage = Math.min(totalPages - 1, currentPage + 1);

                    // Add ellipsis if needed
                    if (startPage > 2) {
                        pageNumbersContainer.innerHTML += '<span class="px-2 text-espresso/30">...</span>';
                    }

                    // Add middle pages
                    for (var i = startPage; i <= endPage; i++) {
                        addPageNumber(pageNumbersContainer, i);
                    }

                    // Add ellipsis if needed
                    if (endPage < totalPages - 1) {
                        pageNumbersContainer.innerHTML += '<span class="px-2 text-espresso/30">...</span>';
                    }

                    // Always show last page if different from first
                    if (totalPages > 1) {
                        addPageNumber(pageNumbersContainer, totalPages);
                    }
                }

                // Add page number function
                function addPageNumber(container, pageNum) {
                    var btn = document.createElement('button');
                    btn.className = 'pagination-btn px-3 py-1 rounded-lg text-sm ' +
                            (pageNum === currentPage ? 'bg-dusty text-whitePure' : 'border border-blush text-espresso/60 hover:text-espresso');
                    btn.textContent = pageNum;
                    btn.onclick = function () {
                        changePage(pageNum);
                    };
                    container.appendChild(btn);
                }

                // Change page function
                function changePage(pageNum) {
                    var totalPages = Math.ceil(filteredRegistrations.length / registrationsPerPage);
                    if (pageNum >= 1 && pageNum <= totalPages && pageNum !== currentPage) {
                        currentPage = pageNum;
                        updateDisplay();
                    }
                }

                // Format date function
                function formatDate(dateString) {
                    var date = new Date(dateString);
                    return date.toLocaleDateString('en-MY', {
                        day: '2-digit',
                        month: 'short',
                        year: 'numeric'
                    });
                }

                // View details modal function
                function viewDetails(instructorId) {
                    var reg = allRegistrations.find(function (r) {
                        return r.id === instructorId;
                    });
                    if (!reg)
                        return;

                    currentDetailsRegId = instructorId;

                    // Handle file paths - add ../ prefix
                    var profileImagePath = reg.profileImagePath ? ('../' + reg.profileImagePath) : '../profile_pictures/instructor/dummy.png';
                    var certificationPath = reg.certification ? ('../' + reg.certification) : '../certifications/instructor/dummy.pdf';

                    var modalContent = document.querySelector('#modalOverlay .modal-content');
                    modalContent.innerHTML =
                            '<div class="p-6">' +
                            '<div class="flex justify-between items-center mb-6">' +
                            '<h3 class="text-xl font-semibold text-espresso">Registration Details</h3>' +
                            '<button onclick="closeModal()" class="text-espresso/60 hover:text-espresso">' +
                            '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                            '</svg>' +
                            '</button>' +
                            '</div>' +
                            '<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">' +
                            '<div class="col-span-1">' +
                            '<div class="w-40 h-40 rounded-lg overflow-hidden bg-petal mx-auto mb-4">' +
                            '<img src="' + profileImagePath + '" alt="Profile" class="w-full h-full object-cover" onerror="this.src=\'../profile_pictures/instructor/dummy.png\'">' +
                            '</div>' +
                            '<h4 class="text-center text-lg font-semibold text-espresso">' + reg.name + '</h4>' +
                            '<p class="text-center text-espresso/60 mb-2">Instructor Applicant</p>' +
                            '<div class="flex justify-center">' +
                            '<span class="px-3 py-1 rounded-full text-sm font-medium ' + getStatusClass(reg.status) + '">' +
                            getStatusText(reg.status) +
                            '</span>' +
                            '</div>' +
                            '</div>' +
                            '<div class="col-span-2 grid grid-cols-1 md:grid-cols-2 gap-4">' +
                            '<div class="bg-cloud rounded-lg p-4">' +
                            '<h5 class="text-sm font-medium text-espresso/60 mb-2">Personal Information</h5>' +
                            '<div class="space-y-2">' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">Email:</span>' +
                            '<p class="text-espresso">' + reg.email + '</p>' +
                            '</div>' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">Phone:</span>' +
                            '<p class="text-espresso">' + reg.phone + '</p>' +
                            '</div>' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">NRIC:</span>' +
                            '<p class="text-espresso">' + reg.nric + '</p>' +
                            '</div>' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">Date of Birth:</span>' +
                            '<p class="text-espresso">' + new Date(reg.bod).toLocaleDateString('en-MY') + '</p>' +
                            '</div>' +
                            '</div>' +
                            '</div>' +
                            '<div class="bg-cloud rounded-lg p-4">' +
                            '<h5 class="text-sm font-medium text-espresso/60 mb-2">Professional Information</h5>' +
                            '<div class="space-y-2">' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">Experience:</span>' +
                            '<p class="text-espresso">' + reg.yearOfExperience + ' year' + (reg.yearOfExperience !== 1 ? 's' : '') + '</p>' +
                            '</div>' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">Registration Date:</span>' +
                            '<p class="text-espresso">' + formatDate(reg.registerDate) + '</p>' +
                            '</div>' +
                            '<div class="mt-3">' +
                            '<span class="text-xs text-espresso/40 block mb-1">Certification:</span>' +
                            '<button onclick="viewPdf(\'' + certificationPath + '\')" class="uniform-button cert-badge hover:certBlueHover">' +
                            '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>' +
                            '</svg>' +
                            '<span>View Certificate</span>' +
                            '</button>' +
                            '</div>' +
                            '</div>' +
                            '</div>' +
                            '</div>' +
                            '</div>' +
                            '<div class="bg-cloud rounded-lg p-4 mb-6">' +
                            '<h5 class="text-sm font-medium text-espresso/60 mb-2">Address</h5>' +
                            '<p class="text-espresso">' + reg.address + '</p>' +
                            '</div>' +
                            '<div class="border-t border-espresso/10 pt-4">' +
                            (reg.status === 'pending' ?
                                    '<div class="flex justify-end gap-3">' +
                                    '<button onclick="showRejectModal(' + reg.id + ', ' + reg.registerID + ')" class="uniform-button bg-dangerBg hover:bg-dangerBg/80 text-dangerText">' +
                                    '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                                    '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                                    '</svg>' +
                                    '<span>Reject</span>' +
                                    '</button>' +
                                    '<button onclick="showApproveModal(' + reg.id + ', ' + reg.registerID + ')" class="uniform-button bg-successBg hover:bg-successBg/80 text-successTextDark">' +
                                    '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                                    '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>' +
                                    '</svg>' +
                                    '<span>Approve</span>' +
                                    '</button>' +
                                    '</div>' :
                                    '<div class="text-center text-espresso/60 italic">' +
                                    'This application has been ' + reg.status + ' on ' + formatDate(reg.registerDate) +
                                    '</div>') +
                            '</div>';

                    document.getElementById('modalOverlay').style.display = 'flex';
                }

                // Get status class function
                function getStatusClass(status) {
                    return 'status-' + status;
                }

                // Get status text function
                function getStatusText(status) {
                    return status.charAt(0).toUpperCase() + status.slice(1);
                }

                // Close modal function
                function closeModal() {
                    document.getElementById('modalOverlay').style.display = 'none';
                    currentDetailsRegId = null;
                }

                // View PDF function
                function viewPdf(pdfUrl) {
                    currentPdfUrl = pdfUrl;
                    var pdfViewer = document.getElementById('pdfViewer');
                    pdfViewer.src = pdfUrl;
                    document.getElementById('pdfModalOverlay').style.display = 'flex';
                }

                // Close PDF modal function
                function closePdfModal() {
                    document.getElementById('pdfModalOverlay').style.display = 'none';
                    var pdfViewer = document.getElementById('pdfViewer');
                    pdfViewer.src = '';
                }

                // Show approve modal function
                function showApproveModal(instructorId, registerId) {
                    currentActionRegId = instructorId;
                    currentActionType = 'approve';

                    // Find registration
                    var reg = allRegistrations.find(function (r) {
                        return r.id === instructorId;
                    });
                    if (!reg)
                        return;

                    var modalContent = document.querySelector('#actionModalOverlay .modal-content');
                    modalContent.innerHTML =
                            '<div class="p-6">' +
                            '<div class="flex justify-between items-center mb-6">' +
                            '<h3 class="text-xl font-semibold text-espresso">Approve Registration</h3>' +
                            '<button onclick="closeActionModal()" class="text-espresso/60 hover:text-espresso">' +
                            '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                            '</svg>' +
                            '</button>' +
                            '</div>' +
                            '<div class="mb-6">' +
                            '<div class="flex items-center gap-3 p-4 bg-successBg/20 rounded-lg">' +
                            '<svg class="w-6 h-6 text-successTextDark flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>' +
                            '</svg>' +
                            '<p class="text-successTextDark text-sm">Are you sure you want to approve this registration?</p>' +
                            '</div>' +
                            '</div>' +
                            '<div class="mb-6">' +
                            '<label class="block text-sm font-medium text-espresso mb-2">Approval Message (Optional)</label>' +
                            '<textarea id="actionMessage" class="w-full border border-blush rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-dusty focus:border-dusty textarea-fixed" rows="4" placeholder="Add a welcome message to the instructor..."></textarea>' +
                            '<p class="text-xs text-espresso/40 mt-1">This message will be sent to the applicant</p>' +
                            '</div>' +
                            '<div class="flex justify-end gap-3">' +
                            '<button onclick="closeActionModal()" class="bg-petal hover:bg-blushHover text-espresso px-6 py-2 rounded-lg font-medium transition-colors duration-200">Cancel</button>' +
                            '<button onclick="processAction(' + registerId + ', ' + instructorId + ')" class="bg-successBg hover:bg-successBg/80 text-successTextDark px-6 py-2 rounded-lg font-medium transition-colors duration-200">Approve Registration</button>' +
                            '</div>' +
                            '</div>';

                    document.getElementById('actionModalOverlay').style.display = 'flex';
                }

                // Show reject modal function
                function showRejectModal(instructorId, registerId) {
                    currentActionRegId = instructorId;
                    currentActionType = 'reject';

                    // Find registration
                    var reg = allRegistrations.find(function (r) {
                        return r.id === instructorId;
                    });
                    if (!reg)
                        return;

                    var modalContent = document.querySelector('#actionModalOverlay .modal-content');
                    modalContent.innerHTML =
                            '<div class="p-6">' +
                            '<div class="flex justify-between items-center mb-6">' +
                            '<h3 class="text-xl font-semibold text-espresso">Reject Registration</h3>' +
                            '<button onclick="closeActionModal()" class="text-espresso/60 hover:text-espresso">' +
                            '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                            '</svg>' +
                            '</button>' +
                            '</div>' +
                            '<div class="mb-6">' +
                            '<div class="flex items-center gap-3 p-4 bg-dangerBg/20 rounded-lg">' +
                            '<svg class="w-6 h-6 text-dangerText flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.998-.833-2.732 0L4.342 16.5c-.77.833.192 2.5 1.732 2.5z"></path>' +
                            '</svg>' +
                            '<p class="text-dangerText text-sm">Are you sure you want to reject this registration?</p>' +
                            '</div>' +
                            '</div>' +
                            '<div class="mb-6">' +
                            '<label class="block text-sm font-medium text-espresso mb-2">Rejection Reason (Required)</label>' +
                            '<textarea id="actionMessage" class="w-full border border-blush rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-dusty focus:border-dusty textarea-fixed" rows="4" placeholder="Please provide a reason for rejection..." required></textarea>' +
                            '<p class="text-xs text-espresso/40 mt-1">This message will be sent to the applicant</p>' +
                            '</div>' +
                            '<div class="flex justify-end gap-3">' +
                            '<button onclick="closeActionModal()" class="bg-petal hover:bg-blushHover text-espresso px-6 py-2 rounded-lg font-medium transition-colors duration-200">Cancel</button>' +
                            '<button onclick="processAction(' + registerId + ', ' + instructorId + ')" class="bg-dangerBg hover:bg-dangerBg/80 text-dangerText px-6 py-2 rounded-lg font-medium transition-colors duration-200">Reject Registration</button>' +
                            '</div>' +
                            '</div>';

                    document.getElementById('actionModalOverlay').style.display = 'flex';
                }

                // Close action modal function
                function closeActionModal() {
                    document.getElementById('actionModalOverlay').style.display = 'none';
                    currentActionRegId = null;
                    currentActionType = null;
                }

                // Process action function - Send to server
                function processAction(registerId, instructorId) {
                    var message = document.getElementById('actionMessage').value;

                    if (currentActionType === 'reject' && !message.trim()) {
                        alert('Please provide a rejection reason.');
                        return;
                    }

                    // Show loading
                    var modalContent = document.querySelector('#actionModalOverlay .modal-content');
                    modalContent.innerHTML =
                            '<div class="p-6">' +
                            '<div class="flex flex-col items-center justify-center py-8">' +
                            '<div class="loading-spinner mb-4"></div>' +
                            '<p class="text-espresso/60">Processing ' + currentActionType + '...</p>' +
                            '</div>' +
                            '</div>';

                    // Prepare data
                    var formData = new FormData();
                    formData.append('action', currentActionType);
                    formData.append('registerID', registerId);
                    formData.append('instructorID', instructorId);
                    formData.append('message', message || '');

                    // Send request
                    var xhr = new XMLHttpRequest();
                    xhr.open('POST', '../register', true);

                    xhr.onreadystatechange = function () {
                        if (xhr.readyState === 4) {
                            if (xhr.status === 200) {
                                try {
                                    var response = JSON.parse(xhr.responseText);
                                    if (response.success) {
                                        // Success - reload data
                                        alert('Registration ' + currentActionType + 'ed successfully!');
                                        loadRegistrations(true);

                                        // Close modal
                                        closeActionModal();

                                        // If details modal is open, close it
                                        if (currentDetailsRegId === currentActionRegId) {
                                            closeModal();
                                        }
                                    } else {
                                        alert('Error: ' + response.message);
                                        closeActionModal();
                                    }
                                } catch (e) {
                                    alert('Error parsing response');
                                    closeActionModal();
                                }
                            } else if (xhr.status === 401) {
                                alert('Session expired. Please login again.');
                                window.location.href = '../general/login.jsp';
                            } else {
                                alert('Server error: ' + xhr.status);
                                closeActionModal();
                            }
                        }
                    };

                    xhr.send(formData);
                }
        </script>

    </body>
</html>