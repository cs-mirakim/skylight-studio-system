<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%
    if (!SessionUtil.checkAdminAccess(session)) {
        if (!SessionUtil.isLoggedIn(session)) {
            response.sendRedirect("../general/login.jsp?error=access_denied&message=Please_login_to_access_admin_pages");
        } else {
            response.sendRedirect("../general/login.jsp?error=admin_access_required&message=Admin_privileges_required_to_access_this_page");
        }
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Monitor Instructor - Skylight Studio</title>

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">

        <script src="https://cdn.tailwindcss.com"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" />
        <script src="https://cdn.jsdelivr.net/jquery/latest/jquery.min.js"></script>
        <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>

        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {
                            sans: ['Roboto', 'ui-sans-serif', 'system-ui'],
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
                            chipTeal: '#6D9B9B'
                        }
                    }
                }
            }
        </script>

        <style>
            .custom-scrollbar::-webkit-scrollbar {
                width: 6px;
            }
            .custom-scrollbar::-webkit-scrollbar-track {
                background: #FDF8F8;
            }
            .custom-scrollbar::-webkit-scrollbar-thumb {
                background: #B36D6D;
                border-radius: 3px;
            }
            .modal-backdrop {
                backdrop-filter: blur(4px);
                background-color: rgba(0, 0, 0, 0.3);
            }
            .rating-excellent { color: #1B5E20; background-color: #A5D6A7; }
            .rating-good { color: #E65100; background-color: #FFCC80; }
            .rating-poor { color: #B71C1C; background-color: #EF9A9A; }
            .chart-container {
                position: relative;
                height: 300px;
                width: 100%;
            }
            .stats-container {
                cursor: default !important;
            }
            .stats-container:hover {
                transform: none !important;
                box-shadow: none !important;
            }
            .pagination-btn {
                transition: all 0.2s ease;
            }
            .pagination-btn:hover:not(.disabled) {
                background-color: #F2D1D1;
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">

            <div class="w-full bg-whitePure py-6 px-6 md:px-8 rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1500px">

                <!-- Page Header -->
                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <h2 class="text-2xl font-semibold mb-1 text-espresso">
                        Monitor Instructor
                    </h2>
                    <p class="text-sm text-espresso/60">
                        Manage and monitor instructor performance, view details, and generate reports
                    </p>
                </div>

                <!-- Quick Stats Overview -->
                <div class="mb-8 grid grid-cols-1 md:grid-cols-4 gap-4">
                    <!-- Total Active Instructors -->
                    <div class="bg-petal p-4 rounded-lg border border-blush stats-container">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm text-espresso/60">Total Active Instructors</p>
                                <p id="statActiveInstructors" class="text-2xl font-bold text-espresso">0</p>
                            </div>
                            <div class="w-10 h-10 rounded-full bg-successBg flex items-center justify-center">
                                <svg class="w-6 h-6 text-successTextDark" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"/>
                                </svg>
                            </div>
                        </div>
                    </div>

                    <!-- Total Inactive Instructors -->
                    <div class="bg-petal p-4 rounded-lg border border-blush stats-container">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm text-espresso/60">Total Inactive</p>
                                <p id="statInactiveInstructors" class="text-2xl font-bold text-espresso">0</p>
                            </div>
                            <div class="w-10 h-10 rounded-full bg-dangerBg flex items-center justify-center">
                                <svg class="w-6 h-6 text-dangerText" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"/>
                                </svg>
                            </div>
                        </div>
                    </div>

                    <!-- Average Overall Rating -->
                    <div class="bg-petal p-4 rounded-lg border border-blush stats-container">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm text-espresso/60">Avg. Overall Rating</p>
                                <p id="statAvgRating" class="text-2xl font-bold text-espresso">0.0</p>
                            </div>
                            <div class="w-10 h-10 rounded-full bg-infoBg flex items-center justify-center">
                                <svg class="w-6 h-6 text-infoText" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/>
                                </svg>
                            </div>
                        </div>
                    </div>

                    <!-- New This Month -->
                    <div class="bg-petal p-4 rounded-lg border border-blush stats-container">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm text-espresso/60">New This Month</p>
                                <p id="statNewThisMonth" class="text-2xl font-bold text-espresso">0</p>
                            </div>
                            <div class="w-10 h-10 rounded-full bg-chipRose flex items-center justify-center">
                                <svg class="w-6 h-6 text-dusty" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v3.586L7.707 9.293a1 1 0 00-1.414 1.414l2.828 2.829a1 1 0 101.415-1.415L11 10.586V7z" clip-rule="evenodd"/>
                                </svg>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Filter Section -->
                <div class="mb-6 bg-petal p-4 rounded-lg border border-blush">
                    <h3 class="text-lg font-medium mb-4 text-espresso">Filter Instructors</h3>
                    <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
                        <!-- Name Filter -->
                        <div>
                            <label class="block text-sm font-medium text-espresso/70 mb-1">Instructor Name</label>
                            <select id="nameFilter" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-teal focus:border-transparent">
                                <option value="">All Instructors</option>
                            </select>
                        </div>

                        <!-- Experience Filter -->
                        <div>
                            <label class="block text-sm font-medium text-espresso/70 mb-1">Experience</label>
                            <select id="experienceFilter" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-teal focus:border-transparent">
                                <option value="">All Experience</option>
                                <option value="1">1 Year</option>
                                <option value="2">2 Years</option>
                                <option value="3">3 Years</option>
                                <option value="4">4 Years</option>
                                <option value="5+">5+ Years</option>
                            </select>
                        </div>

                        <!-- Date Joined Filter -->
                        <div>
                            <label class="block text-sm font-medium text-espresso/70 mb-1">Date Joined</label>
                            <input type="text" id="dateRangeFilter" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-teal focus:border-transparent" placeholder="Select date range">
                        </div>

                        <!-- Status Filter -->
                        <div>
                            <label class="block text-sm font-medium text-espresso/70 mb-1">Status</label>
                            <select id="statusFilter" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-teal focus:border-transparent">
                                <option value="">All Status</option>
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                            </select>
                        </div>

                        <!-- Filter Buttons -->
                        <div class="flex items-end space-x-2">
                            <button id="applyFilterBtn" class="px-4 py-2 bg-dusty text-whitePure rounded-lg hover:bg-dustyHover transition-colors focus:outline-none focus:ring-2 focus:ring-dusty focus:ring-offset-2">
                                Apply Filters
                            </button>
                            <button id="resetFilterBtn" class="px-4 py-2 border border-dusty text-dusty rounded-lg hover:bg-blush transition-colors focus:outline-none focus:ring-2 focus:ring-dusty focus:ring-offset-2">
                                Reset
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Instructor List Table -->
                <div class="flex-1 overflow-hidden">
                    <div class="bg-whitePure rounded-lg border border-blush overflow-hidden">
                        <div class="overflow-x-auto">
                            <table class="min-w-full divide-y divide-blush">
                                <thead class="bg-petal">
                                    <tr>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Instructor</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Experience</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Date Joined</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Status</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="instructorTableBody" class="bg-whitePure divide-y divide-blush">
                                    <tr id="loadingRow">
                                        <td colspan="5" class="px-6 py-12 text-center">
                                            <div class="text-espresso/60">
                                                Loading instructors...
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <!-- Pagination -->
                        <div class="bg-petal px-6 py-4 border-t border-blush flex items-center justify-between">
                            <div class="text-sm text-espresso/60">
                                Showing <span id="paginationStart">0</span> to <span id="paginationEnd">0</span> of <span id="paginationTotal">0</span> instructors
                            </div>
                            <div class="flex space-x-2">
                                <button id="prevPageBtn" class="pagination-btn px-3 py-1 rounded border border-blush text-espresso disabled:opacity-50 disabled:cursor-not-allowed" disabled>
                                    Previous
                                </button>
                                <div class="flex space-x-1" id="pageNumbers">
                                </div>
                                <button id="nextPageBtn" class="pagination-btn px-3 py-1 rounded border border-blush text-espresso disabled:opacity-50 disabled:cursor-not-allowed" disabled>
                                    Next
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

        </main>

        <!-- View Details Modal -->
        <div id="detailsModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0 transition-opacity" onclick="closeDetails()"></div>

            <div class="fixed inset-0 overflow-y-auto">
                <div class="flex items-center justify-center min-h-full p-4">
                    <div class="relative bg-whitePure rounded-lg shadow-xl border border-blush w-full max-w-4xl">
                        <!-- Modal Header -->
                        <div class="flex items-center justify-between p-6 border-b border-blush">
                            <div>
                                <h3 class="text-xl font-semibold text-espresso">Instructor Details</h3>
                                <p class="text-sm text-espresso/60 mt-1">Complete profile information</p>
                            </div>
                            <button onclick="closeDetails()" class="text-espresso/40 hover:text-espresso">
                                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                                </svg>
                            </button>
                        </div>

                        <!-- Modal Content -->
                        <div class="p-6">
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                                <!-- Left Column - Profile -->
                                <div class="md:col-span-1">
                                    <div class="bg-petal rounded-lg p-4 border border-blush">
                                        <div class="flex flex-col items-center">
                                            <img id="detailProfileImg" class="w-32 h-32 rounded-full object-cover border-4 border-whitePure shadow mb-4" src="../profile_pictures/instructor/dummy.png" alt="Profile">
                                            <h4 id="detailName" class="text-lg font-semibold text-espresso">Loading...</h4>
                                            <p id="detailEmail" class="text-sm text-espresso/60 mb-4">Loading...</p>

                                            <div class="w-full space-y-3">
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Phone</label>
                                                    <p id="detailPhone" class="text-sm text-espresso">Loading...</p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">NRIC</label>
                                                    <p id="detailNRIC" class="text-sm text-espresso">Loading...</p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Date of Birth</label>
                                                    <p id="detailBOD" class="text-sm text-espresso">Loading...</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Certification Section -->
                                    <div class="mt-4 bg-petal rounded-lg p-4 border border-blush">
                                        <h5 class="font-medium text-espresso mb-3">Certification</h5>
                                        <div class="space-y-2">
                                            <div class="flex items-center justify-between">
                                                <span id="certFileName" class="text-sm text-espresso">No certification uploaded</span>
                                                <button onclick="viewCertification()" class="text-xs text-teal hover:text-tealHover px-2 py-1 rounded border border-teal hover:bg-teal/5 transition-colors">View PDF</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Right Column - Details -->
                                <div class="md:col-span-2">
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        <!-- Registration Details -->
                                        <div class="bg-petal rounded-lg p-4 border border-blush">
                                            <h5 class="font-medium text-espresso mb-3">Registration Details</h5>
                                            <div class="space-y-2">
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Register Date</label>
                                                    <p id="detailRegDate" class="text-sm text-espresso">Loading...</p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Registration Status</label>
                                                    <p id="detailRegStatus" class="text-sm text-espresso">
                                                        <span class="px-2 py-1 text-xs rounded-full">Loading...</span>
                                                    </p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">User Type</label>
                                                    <p id="detailUserType" class="text-sm text-espresso">Instructor</p>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Professional Details -->
                                        <div class="bg-petal rounded-lg p-4 border border-blush">
                                            <h5 class="font-medium text-espresso mb-3">Professional Details</h5>
                                            <div class="space-y-2">
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Years of Experience</label>
                                                    <p id="detailExperience" class="text-sm text-espresso">Loading...</p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Date Joined</label>
                                                    <p id="detailDateJoined" class="text-sm text-espresso">Loading...</p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">System Status</label>
                                                    <p id="detailStatus" class="text-sm text-espresso">
                                                        <span class="px-2 py-1 text-xs rounded-full">Loading...</span>
                                                    </p>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Address -->
                                        <div class="md:col-span-2 bg-petal rounded-lg p-4 border border-blush">
                                            <h5 class="font-medium text-espresso mb-3">Address</h5>
                                            <p id="detailAddress" class="text-sm text-espresso">Loading...</p>
                                        </div>

                                        <!-- Performance Summary -->
                                        <div class="md:col-span-2 bg-petal rounded-lg p-4 border border-blush">
                                            <div class="flex items-center justify-between mb-3">
                                                <h5 class="font-medium text-espresso">Performance Summary</h5>
                                                <button onclick="showPerformance()" class="text-sm text-teal hover:text-tealHover flex items-center px-3 py-1 rounded border border-teal hover:bg-teal/5 transition-colors">
                                                    <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.414L11 9.586V6z" clip-rule="evenodd"/>
                                                    </svg>
                                                    View Detailed Performance
                                                </button>
                                            </div>
                                            <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
                                                <div class="text-center">
                                                    <div id="statTotalClasses" class="text-2xl font-bold text-espresso">0</div>
                                                    <div class="text-xs text-espresso/60">Total Classes</div>
                                                </div>
                                                <div class="text-center">
                                                    <div id="statCancelled" class="text-2xl font-bold text-espresso">0</div>
                                                    <div class="text-xs text-espresso/60">Cancelled</div>
                                                </div>
                                                <div class="text-center">
                                                    <div id="statAvgRating" class="text-2xl font-bold text-espresso">0</div>
                                                    <div class="text-xs text-espresso/60">Avg Rating</div>
                                                </div>
                                                <div class="text-center">
                                                    <div id="statFeedbacks" class="text-2xl font-bold text-espresso">0</div>
                                                    <div class="text-xs text-espresso/60">Feedbacks</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Separator and Action Buttons -->
                                    <div class="mt-8 pt-6 border-t border-blush flex justify-end space-x-3">
                                        <button onclick="exportPerformancePDF()" class="px-4 py-2 bg-teal text-whitePure rounded-lg hover:bg-tealHover transition-colors flex items-center">
                                            <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                                            <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd"/>
                                            </svg>
                                            Export Performance Report
                                        </button>
                                        <button onclick="closeDetails()" class="px-4 py-2 border border-dusty text-dusty rounded-lg hover:bg-blush transition-colors">
                                            Close
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Performance Modal -->
        <div id="performanceModal" class="fixed inset-0 z-[60] hidden">
            <div class="fixed inset-0 bg-black/50" onclick="closePerformance()"></div>

            <div class="fixed inset-0 overflow-y-auto">
                <div class="flex items-center justify-center min-h-full p-4">
                    <div class="relative bg-whitePure rounded-lg shadow-xl border border-blush w-full max-w-6xl">
                        <!-- Modal Header -->
                        <div class="flex items-center justify-between p-6 border-b border-blush">
                            <div>
                                <h3 class="text-xl font-semibold text-espresso">Performance Analysis</h3>
                                <p class="text-sm text-espresso/60 mt-1" id="performanceInstructorName">Loading...</p>
                            </div>
                            <div class="flex items-center space-x-4">
                                <!-- Time Period Selector -->
                                <select id="timePeriod" onchange="updateChartsWithPeriod()" class="px-3 py-1 border border-blush rounded-lg bg-whitePure text-sm focus:outline-none focus:ring-2 focus:ring-teal">
                                    <option value="3months">Last 3 Months</option>
                                    <option value="6months">Last 6 Months</option>
                                    <option value="1year">Last 1 Year</option>
                                    <option value="all">All Time</option>
                                </select>

                                <button onclick="closePerformance()" class="text-espresso/40 hover:text-espresso">
                                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                                    </svg>
                                </button>
                            </div>
                        </div>

                        <!-- Modal Content -->
                        <div class="p-6">
                            <!-- Performance Metrics Cards -->
                            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                                <div class="bg-petal p-4 rounded-lg border border-blush">
                                    <div class="text-2xl font-bold text-espresso" id="perfOverallRating">0.0</div>
                                    <div class="text-xs text-espresso/60">Overall Rating</div>
                                </div>
                                <div class="bg-petal p-4 rounded-lg border border-blush">
                                    <div class="text-2xl font-bold text-espresso" id="perfTotalClasses">0</div>
                                    <div class="text-xs text-espresso/60">Total Classes</div>
                                </div>
                                <div class="bg-petal p-4 rounded-lg border border-blush">
                                    <div class="text-2xl font-bold text-espresso" id="perfCancelled">0</div>
                                    <div class="text-xs text-espresso/60">Cancelled Classes</div>
                                </div>
                                <div class="bg-petal p-4 rounded-lg border border-blush">
                                    <div class="text-2xl font-bold text-espresso" id="perfCompletion">0%</div>
                                    <div class="text-xs text-espresso/60">Completion Rate</div>
                                </div>
                            </div>

                            <!-- Charts Grid -->
                            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
                                <!-- Category Ratings Chart -->
                                <div class="bg-whitePure p-4 rounded-lg border border-blush">
                                    <h4 class="font-medium text-espresso mb-4">Rating by Category</h4>
                                    <div class="chart-container">
                                        <canvas id="categoryChart"></canvas>
                                    </div>
                                </div>

                                <!-- Monthly Trend Chart -->
                                <div class="bg-whitePure p-4 rounded-lg border border-blush">
                                    <h4 class="font-medium text-espresso mb-4">Monthly Performance Trend</h4>
                                    <div class="chart-container">
                                        <canvas id="trendChart"></canvas>
                                    </div>
                                </div>

                                <!-- Class Distribution Chart -->
                                <div class="bg-whitePure p-4 rounded-lg border border-blush">
                                    <h4 class="font-medium text-espresso mb-4">Class Distribution</h4>
                                    <div class="chart-container">
                                        <canvas id="distributionChart"></canvas>
                                    </div>
                                </div>

                                <!-- Rating Breakdown Table -->
                                <div class="bg-whitePure p-4 rounded-lg border border-blush">
                                    <h4 class="font-medium text-espresso mb-4">Rating Breakdown</h4>
                                    <div class="overflow-x-auto">
                                        <table class="min-w-full">
                                            <thead>
                                                <tr class="border-b border-blush">
                                                    <th class="text-left py-2 text-sm font-medium text-espresso">Category</th>
                                                    <th class="text-left py-2 text-sm font-medium text-espresso">Average</th>
                                                    <th class="text-left py-2 text-sm font-medium text-espresso">Highest</th>
                                                    <th class="text-left py-2 text-sm font-medium text-espresso">Lowest</th>
                                                </tr>
                                            </thead>
                                            <tbody id="ratingBreakdownBody">
                                                <!-- Data will be populated by JavaScript -->
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>

                            <!-- Action Buttons -->
                            <div class="flex justify-end space-x-3">
                                <button onclick="exportDetailedPDF()" class="px-4 py-2 bg-teal text-whitePure rounded-lg hover:bg-tealHover transition-colors flex items-center">
                                    <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd"/>
                                    </svg>
                                    Export This Report
                                </button>
                                <button onclick="closePerformance()" class="px-4 py-2 border border-dusty text-dusty rounded-lg hover:bg-blush transition-colors">
                                    Close
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Certification Viewer Modal -->
        <div id="certModal" class="fixed inset-0 z-[70] hidden">
            <div class="fixed inset-0 bg-black/70" onclick="closeCert()"></div>

            <div class="fixed inset-0 flex items-center justify-center p-2 sm:p-4">
                <div class="bg-whitePure rounded-lg shadow-2xl w-full max-w-5xl h-[95vh] flex flex-col">

                    <div class="flex items-center justify-between p-4 border-b border-blush">
                        <h3 id="certModalTitle" class="text-lg font-semibold text-espresso">Certification Document</h3>
                        <button onclick="closeCert()" class="text-espresso/40 hover:text-espresso">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                            </svg>
                        </button>
                    </div>

                    <div class="flex-1 overflow-hidden p-2">
                        <iframe id="certFrame" src="" class="w-full h-full border border-blush rounded"></iframe>
                    </div>

                    <div class="p-4 border-t border-blush flex justify-end">
                        <button onclick="closeCert()" class="px-4 py-2 border border-dusty text-dusty rounded-lg hover:bg-blush transition-colors">
                            Close
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- PDF Preview Modal -->
        <div id="pdfPreviewModal" class="fixed inset-0 z-[80] hidden">
            <div class="fixed inset-0 bg-black/70" onclick="closePDFPreview()"></div>

            <div class="fixed inset-0 flex items-center justify-center p-2 sm:p-4">
                <div class="bg-whitePure rounded-lg shadow-2xl w-full max-w-6xl h-[95vh] flex flex-col">

                    <div class="flex items-center justify-between p-4 border-b border-blush">
                        <h3 id="pdfPreviewTitle" class="text-lg font-semibold text-espresso">Preview Instructor Report</h3>
                        <div class="flex items-center space-x-3">
                            <button id="pdfDownloadBtn" class="px-4 py-2 bg-teal text-whitePure rounded-lg hover:bg-tealHover transition-colors flex items-center">
                                <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd"/>
                                </svg>
                                Download PDF
                            </button>
                            <button onclick="closePDFPreview()" class="text-espresso/40 hover:text-espresso">
                                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                                </svg>
                            </button>
                        </div>
                    </div>

                    <div class="flex-1 overflow-hidden p-2">
                        <iframe id="pdfPreviewFrame" class="w-full h-full border border-blush rounded" frameborder="0"></iframe>
                    </div>

                    <div class="p-4 border-t border-blush flex justify-between items-center">
                        <span class="text-sm text-espresso/60">
                            Preview generated: <span id="pdfGenerationTime"></span>
                        </span>
                        <div class="space-x-3">
                            <button onclick="closePDFPreview()" class="px-4 py-2 border border-dusty text-dusty rounded-lg hover:bg-blush transition-colors">
                                Close Preview
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Deactivate/Activate Confirmation Modal -->
        <div id="activateDeactivateModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0" onclick="closeActivateDeactivate()"></div>
            <div class="fixed inset-0 flex items-center justify-center p-4">
                <div class="bg-whitePure rounded-lg shadow-xl border border-blush w-full max-w-md">
                    <div class="p-6">
                        <div id="modalIcon" class="flex items-center justify-center w-12 h-12 mx-auto mb-4 rounded-full">
                        </div>
                        <h3 id="modalTitle" class="text-lg font-semibold text-center text-espresso mb-2"></h3>
                        <p id="modalText" class="text-sm text-espresso/70 text-center mb-6">
                        </p>
                        <div class="flex justify-center space-x-3">
                            <button onclick="confirmActivateDeactivate()" id="confirmButton" class="px-4 py-2 text-whitePure rounded-lg transition-colors">
                                Confirm
                            </button>
                            <button onclick="closeActivateDeactivate()" class="px-4 py-2 border border-dusty text-dusty rounded-lg hover:bg-blush transition-colors">
                                Cancel
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
                                // Global variables - ES5 compatible
                                var currentInstructorId = null;
                                var chartInstances = {};
                                var currentPage = 1;
                                var itemsPerPage = 10;
                                var filteredInstructors = [];
                                var allInstructors = [];
                                var currentCertificationPath = '';
                                var currentPerformanceData = null;

                                // Initialize the page
                                document.addEventListener('DOMContentLoaded', function () {
                                    initDateRangePicker();
                                    loadStats();
                                    loadInstructors();
                                    initEventListeners();
                                });

                                function initDateRangePicker() {
                                    $('#dateRangeFilter').daterangepicker({
                                        opens: 'left',
                                        drops: 'down',
                                        locale: {
                                            format: 'DD/MM/YYYY',
                                            applyLabel: 'Apply',
                                            cancelLabel: 'Cancel'
                                        }
                                    });
                                }

                                function initEventListeners() {
                                    document.getElementById('applyFilterBtn').addEventListener('click', applyFilters);
                                    document.getElementById('resetFilterBtn').addEventListener('click', resetFilters);
                                    document.getElementById('prevPageBtn').addEventListener('click', goToPrevPage);
                                    document.getElementById('nextPageBtn').addEventListener('click', goToNextPage);
                                }

                                // Load statistics
                                function loadStats() {
                                    fetch('monitor-instructor?action=stats')
                                            .then(function (response) {
                                                if (!response.ok)
                                                    throw new Error('Network response was not ok');
                                                return response.text();
                                            })
                                            .then(function (xmlText) {
                                                var parser = new DOMParser();
                                                var xmlDoc = parser.parseFromString(xmlText, 'text/xml');

                                                var active = getXmlValue(xmlDoc, 'active');
                                                var inactive = getXmlValue(xmlDoc, 'inactive');
                                                var newThisMonth = getXmlValue(xmlDoc, 'newThisMonth');
                                                var avgOverallRating = getXmlValue(xmlDoc, 'avgOverallRating');

                                                document.getElementById('statActiveInstructors').textContent = active;
                                                document.getElementById('statInactiveInstructors').textContent = inactive;
                                                document.getElementById('statNewThisMonth').textContent = newThisMonth;
                                                document.getElementById('statAvgRating').textContent = avgOverallRating;
                                            })
                                            .catch(function (error) {
                                                console.error('Error loading stats:', error);
                                                alert('Error loading statistics: ' + error.message);
                                            });
                                }

                                // Load instructors from server
                                function loadInstructors() {
                                    fetch('monitor-instructor?action=list')
                                            .then(function (response) {
                                                if (!response.ok)
                                                    throw new Error('Network response was not ok');
                                                return response.text();
                                            })
                                            .then(function (xmlText) {
                                                var parser = new DOMParser();
                                                var xmlDoc = parser.parseFromString(xmlText, 'text/xml');

                                                allInstructors = [];
                                                var instructorElements = xmlDoc.getElementsByTagName('instructor');
                                                var nameFilter = document.getElementById('nameFilter');

                                                while (nameFilter.options.length > 1) {
                                                    nameFilter.remove(1);
                                                }

                                                for (var i = 0; i < instructorElements.length; i++) {
                                                    var element = instructorElements[i];

                                                    var instructor = {
                                                        id: element.getElementsByTagName('id')[0].textContent,
                                                        name: element.getElementsByTagName('name')[0].textContent,
                                                        email: element.getElementsByTagName('email')[0].textContent,
                                                        experience: element.getElementsByTagName('experience')[0].textContent,
                                                        dateJoined: element.getElementsByTagName('dateJoined')[0].textContent,
                                                        status: element.getElementsByTagName('status')[0].textContent,
                                                        registrationStatus: element.getElementsByTagName('registrationStatus')[0].textContent,
                                                        // ✅ ADD: Profile image
                                                        profileImage: element.getElementsByTagName('profileImage')[0] ?
                                                                element.getElementsByTagName('profileImage')[0].textContent :
                                                                '../profile_pictures/instructor/dummy.png'
                                                    };

                                                    allInstructors.push(instructor);

                                                    var option = document.createElement('option');
                                                    option.value = instructor.id;
                                                    option.textContent = instructor.name;
                                                    nameFilter.appendChild(option);
                                                }

                                                filteredInstructors = allInstructors.slice();
                                                renderInstructorTable();
                                            })
                                            .catch(function (error) {
                                                console.error('Error loading instructors:', error);
                                                document.getElementById('instructorTableBody').innerHTML =
                                                        '<tr><td colspan="5" class="px-6 py-12 text-center text-red-500">' +
                                                        'Error loading instructors: ' + error.message + '</td></tr>';
                                            });
                                }

                                // Render instructor table based on current page
                                function renderInstructorTable() {
                                    var tableBody = document.getElementById('instructorTableBody');

                                    // Remove loading row
                                    var loadingRow = document.getElementById('loadingRow');
                                    if (loadingRow) {
                                        loadingRow.remove();
                                    }

                                    tableBody.innerHTML = '';

                                    // Calculate start and end indices
                                    var startIndex = (currentPage - 1) * itemsPerPage;
                                    var endIndex = Math.min(startIndex + itemsPerPage, filteredInstructors.length);

                                    // Update pagination info
                                    document.getElementById('paginationStart').textContent = startIndex + 1;
                                    document.getElementById('paginationEnd').textContent = endIndex;
                                    document.getElementById('paginationTotal').textContent = filteredInstructors.length;

                                    // Update pagination buttons
                                    document.getElementById('prevPageBtn').disabled = (currentPage === 1);
                                    document.getElementById('nextPageBtn').disabled = (currentPage === Math.ceil(filteredInstructors.length / itemsPerPage));

                                    // Render page numbers
                                    renderPageNumbers();

                                    // Render table rows
                                    for (var i = startIndex; i < endIndex; i++) {
                                        var instructor = filteredInstructors[i];
                                        var row = createInstructorRow(instructor);
                                        tableBody.appendChild(row);
                                    }

                                    // Show empty state if no results
                                    if (filteredInstructors.length === 0) {
                                        var emptyRow = document.createElement('tr');
                                        emptyRow.innerHTML = '<td colspan="5" class="px-6 py-12 text-center">' +
                                                '<div class="text-espresso/40">' +
                                                '<svg class="mx-auto h-12 w-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>' +
                                                '</svg>' +
                                                '<p class="text-lg font-medium">No instructors found</p>' +
                                                '<p class="text-sm mt-1">Try adjusting your filters</p>' +
                                                '<button onclick="resetFilters()" class="mt-4 px-4 py-2 bg-dusty text-whitePure rounded-lg hover:bg-dustyHover transition-colors">' +
                                                'Reset Filters' +
                                                '</button>' +
                                                '</div>' +
                                                '</td>';
                                        tableBody.appendChild(emptyRow);
                                    }
                                }

                                // Create instructor table row
                                function createInstructorRow(instructor) {
                                    var row = document.createElement('tr');
                                    row.className = 'hover:bg-cloud';

                                    // Determine status badge
                                    var statusBadge = '';
                                    if (instructor.status === 'active') {
                                        statusBadge = '<span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-successBg text-successTextDark">Active</span>';
                                    } else {
                                        statusBadge = '<span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-dangerBg text-dangerText">Inactive</span>';
                                    }

                                    var actionButtonText = instructor.status === 'active' ? 'Deactivate' : 'Activate';
                                    var actionButtonClass = instructor.status === 'active' ? 'text-dusty hover:text-dustyHover' : 'text-teal hover:text-tealHover';
                                    var actionButtonBorder = instructor.status === 'active' ? 'border-dusty' : 'border-teal';

                                    // ✅ FIX: Use instructor.profileImage if available, else use dummy
                                    var imgSrc = instructor.profileImage || '../profile_pictures/instructor/dummy.png';

                                    row.innerHTML = '<td class="px-6 py-4 whitespace-nowrap">' +
                                            '<div class="flex items-center">' +
                                            '<div class="flex-shrink-0 h-10 w-10">' +
                                            '<img class="h-10 w-10 rounded-full object-cover" src="' + imgSrc + '" alt="' + instructor.name + '">' +
                                            '</div>' +
                                            '<div class="ml-4">' +
                                            '<div class="text-sm font-medium text-espresso">' + instructor.name + '</div>' +
                                            '<div class="text-sm text-espresso/60">' + instructor.email + '</div>' +
                                            '</div>' +
                                            '</div>' +
                                            '</td>' +
                                            '<td class="px-6 py-4 whitespace-nowrap">' +
                                            '<div class="text-sm text-espresso">' + instructor.experience + '</div>' +
                                            '</td>' +
                                            '<td class="px-6 py-4 whitespace-nowrap">' +
                                            '<div class="text-sm text-espresso">' + instructor.dateJoined + '</div>' +
                                            '</td>' +
                                            '<td class="px-6 py-4 whitespace-nowrap">' +
                                            statusBadge +
                                            '</td>' +
                                            '<td class="px-6 py-4 whitespace-nowrap text-sm font-medium">' +
                                            '<button onclick="showDetails(' + instructor.id + ')" class="text-teal hover:text-tealHover mr-3 px-3 py-1 rounded border border-teal hover:bg-teal/5 transition-colors">View Details</button>' +
                                            '<button onclick="toggleActivateInstructor(' + instructor.id + ')" class="' + actionButtonClass + ' px-3 py-1 rounded border ' + actionButtonBorder + ' hover:bg-' + (instructor.status === 'active' ? 'dusty' : 'teal') + '/5 transition-colors">' +
                                            actionButtonText +
                                            '</button>' +
                                            '</td>';

                                    return row;
                                }

                                // Render page numbers
                                function renderPageNumbers() {
                                    var pageNumbersContainer = document.getElementById('pageNumbers');
                                    pageNumbersContainer.innerHTML = '';

                                    var totalPages = Math.ceil(filteredInstructors.length / itemsPerPage);
                                    if (totalPages <= 0)
                                        return;

                                    // Always show first page
                                    addPageButton(1);

                                    // Show ellipsis if needed
                                    if (currentPage > 3) {
                                        var ellipsis = document.createElement('span');
                                        ellipsis.className = 'px-3 py-1';
                                        ellipsis.textContent = '...';
                                        pageNumbersContainer.appendChild(ellipsis);
                                    }

                                    // Show pages around current page
                                    var startPage = Math.max(2, currentPage - 1);
                                    var endPage = Math.min(totalPages - 1, currentPage + 1);

                                    for (var i = startPage; i <= endPage; i++) {
                                        addPageButton(i);
                                    }

                                    // Show ellipsis if needed
                                    if (currentPage < totalPages - 2) {
                                        var ellipsis = document.createElement('span');
                                        ellipsis.className = 'px-3 py-1';
                                        ellipsis.textContent = '...';
                                        pageNumbersContainer.appendChild(ellipsis);
                                    }

                                    // Always show last page if more than 1 page
                                    if (totalPages > 1) {
                                        addPageButton(totalPages);
                                    }
                                }

                                function addPageButton(pageNumber) {
                                    var pageNumbersContainer = document.getElementById('pageNumbers');
                                    var button = document.createElement('button');
                                    button.className = 'pagination-btn px-3 py-1 rounded border ' +
                                            (pageNumber === currentPage ? 'bg-dusty text-whitePure' : 'border-blush text-espresso');
                                    button.textContent = pageNumber;
                                    button.onclick = function () {
                                        goToPage(pageNumber);
                                    };
                                    pageNumbersContainer.appendChild(button);
                                }

                                // Pagination functions
                                function goToPage(page) {
                                    currentPage = page;
                                    renderInstructorTable();
                                }

                                function goToPrevPage() {
                                    if (currentPage > 1) {
                                        currentPage--;
                                        renderInstructorTable();
                                    }
                                }

                                function goToNextPage() {
                                    var totalPages = Math.ceil(filteredInstructors.length / itemsPerPage);
                                    if (currentPage < totalPages) {
                                        currentPage++;
                                        renderInstructorTable();
                                    }
                                }

                                // Filter functions
                                function applyFilters() {
                                    var name = document.getElementById('nameFilter').value;
                                    var experience = document.getElementById('experienceFilter').value;
                                    var status = document.getElementById('statusFilter').value;

                                    filteredInstructors = allInstructors.filter(function (instructor) {
                                        var matches = true;

                                        // Filter by name
                                        if (name && name !== "" && instructor.id !== name) {
                                            matches = false;
                                        }

                                        // Filter by experience
                                        if (experience && matches) {
                                            if (experience === '5+') {
                                                if (!instructor.experience.includes('+') && !instructor.experience.includes('5')) {
                                                    matches = false;
                                                }
                                            } else if (!instructor.experience.includes(experience)) {
                                                matches = false;
                                            }
                                        }

                                        // Filter by status
                                        if (status && matches && instructor.status !== status) {
                                            matches = false;
                                        }

                                        return matches;
                                    });

                                    // Reset to first page
                                    currentPage = 1;
                                    renderInstructorTable();
                                }

                                function resetFilters() {
                                    document.getElementById('nameFilter').value = '';
                                    document.getElementById('experienceFilter').value = '';
                                    document.getElementById('dateRangeFilter').value = '';
                                    document.getElementById('statusFilter').value = '';

                                    filteredInstructors = allInstructors.slice();
                                    currentPage = 1;
                                    renderInstructorTable();
                                }

                                // Load instructor details
                                function showDetails(instructorId) {
                                    currentInstructorId = instructorId;

                                    fetch('monitor-instructor?action=details&id=' + instructorId)
                                            .then(function (response) {
                                                if (!response.ok)
                                                    throw new Error('Network response was not ok');
                                                return response.text();
                                            })
                                            .then(function (xmlText) {
                                                var parser = new DOMParser();
                                                var xmlDoc = parser.parseFromString(xmlText, 'text/xml');

                                                // Update basic information
                                                document.getElementById('detailName').textContent = getXmlValue(xmlDoc, 'name');
                                                document.getElementById('detailEmail').textContent = getXmlValue(xmlDoc, 'email');
                                                document.getElementById('detailPhone').textContent = getXmlValue(xmlDoc, 'phone');
                                                document.getElementById('detailNRIC').textContent = getXmlValue(xmlDoc, 'nric');
                                                document.getElementById('detailBOD').textContent = getXmlValue(xmlDoc, 'bod');
                                                document.getElementById('detailRegDate').textContent = getXmlValue(xmlDoc, 'regDate');
                                                document.getElementById('detailExperience').textContent = getXmlValue(xmlDoc, 'experience');
                                                document.getElementById('detailDateJoined').textContent = getXmlValue(xmlDoc, 'dateJoined');
                                                document.getElementById('detailAddress').textContent = getXmlValue(xmlDoc, 'address');

                                                // Update profile image
                                                var profileImage = getXmlValue(xmlDoc, 'profileImage');
                                                if (profileImage && profileImage !== 'Not available') {
                                                    document.getElementById('detailProfileImg').src = profileImage;
                                                } else {
                                                    document.getElementById('detailProfileImg').src = '../profile_pictures/instructor/dummy.png';
                                                }

                                                // Update certification
                                                var certification = getXmlValue(xmlDoc, 'certification');
                                                var certificationFileName = getXmlValue(xmlDoc, 'certificationFileName');

                                                if (certificationFileName && certificationFileName !== 'Not available' && certificationFileName !== 'dummy.pdf') {
                                                    document.getElementById('certFileName').textContent = certificationFileName;
                                                } else {
                                                    document.getElementById('certFileName').textContent = 'No certification uploaded';
                                                }

                                                // Store certification path
                                                currentCertificationPath = certification;

                                                // Get all 5 ratings and calculate average
                                                var avgTeaching = parseFloat(getXmlValue(xmlDoc, 'avgTeaching')) || 0;
                                                var avgCommunication = parseFloat(getXmlValue(xmlDoc, 'avgCommunication')) || 0;
                                                var avgSupport = parseFloat(getXmlValue(xmlDoc, 'avgSupport')) || 0;
                                                var avgPunctuality = parseFloat(getXmlValue(xmlDoc, 'avgPunctuality')) || 0;
                                                var avgOverallRating = parseFloat(getXmlValue(xmlDoc, 'overallRating')) || 0;

                                                // Calculate average from 5 ratings
                                                var totalAllRatings = avgTeaching + avgCommunication + avgSupport + avgPunctuality + avgOverallRating;
                                                var averageAllRatings = totalAllRatings / 5;

                                                if (isNaN(averageAllRatings) || averageAllRatings === Infinity) {
                                                    averageAllRatings = 0;
                                                }

                                                // Update performance summary
                                                var totalClasses = getXmlValue(xmlDoc, 'totalClasses');
                                                var cancelledClasses = getXmlValue(xmlDoc, 'cancelledClasses');
                                                var feedbackCount = getXmlValue(xmlDoc, 'feedbackCount');

                                                document.getElementById('statTotalClasses').textContent = totalClasses;
                                                document.getElementById('statCancelled').textContent = cancelledClasses;
                                                document.getElementById('statAvgRating').textContent = averageAllRatings.toFixed(1);
                                                document.getElementById('statFeedbacks').textContent = feedbackCount;

                                                // Update status badges
                                                var regStatus = getXmlValue(xmlDoc, 'regStatus');
                                                var regStatusEl = document.getElementById('detailRegStatus');
                                                if (regStatus === 'approved') {
                                                    regStatusEl.innerHTML = '<span class="px-2 py-1 text-xs rounded-full bg-successBg text-successTextDark">Approved</span>';
                                                } else if (regStatus === 'pending') {
                                                    regStatusEl.innerHTML = '<span class="px-2 py-1 text-xs rounded-full bg-warningBg text-warningText">Pending</span>';
                                                } else {
                                                    regStatusEl.innerHTML = '<span class="px-2 py-1 text-xs rounded-full bg-dangerBg text-dangerText">' + regStatus.charAt(0).toUpperCase() + regStatus.slice(1) + '</span>';
                                                }

                                                var instructorStatus = getXmlValue(xmlDoc, 'instructorStatus');
                                                var statusEl = document.getElementById('detailStatus');
                                                if (instructorStatus === 'active') {
                                                    statusEl.innerHTML = '<span class="px-2 py-1 text-xs rounded-full bg-successBg text-successTextDark">Active</span>';
                                                } else {
                                                    statusEl.innerHTML = '<span class="px-2 py-1 text-xs rounded-full bg-dangerBg text-dangerText">Inactive</span>';
                                                }

                                                // Show modal
                                                document.getElementById('detailsModal').classList.remove('hidden');
                                            })
                                            .catch(function (error) {
                                                console.error('Error loading details:', error);
                                                alert('Error loading instructor details: ' + error.message);
                                            });
                                }

                                function getXmlValue(xmlDoc, tagName) {
                                    var elements = xmlDoc.getElementsByTagName(tagName);
                                    if (elements.length > 0) {
                                        return elements[0].textContent;
                                    }
                                    return 'Not available';
                                }

                                function closeDetails() {
                                    document.getElementById('detailsModal').classList.add('hidden');
                                    currentInstructorId = null;
                                }

                                // NEW: Load performance data with period filter
                                function showPerformance() {
                                    if (!currentInstructorId)
                                        return;

                                    var period = document.getElementById('timePeriod') ?
                                            document.getElementById('timePeriod').value : 'all';

                                    fetch('monitor-instructor?action=completePerformance&id=' + currentInstructorId + '&period=' + period)
                                            .then(function (response) {
                                                if (!response.ok)
                                                    throw new Error('Network response was not ok');
                                                return response.text();
                                            })
                                            .then(function (xmlText) {
                                                var parser = new DOMParser();
                                                var xmlDoc = parser.parseFromString(xmlText, 'text/xml');

                                                // Check for XML error
                                                var errorElement = xmlDoc.querySelector('parsererror');
                                                if (errorElement) {
                                                    throw new Error('Invalid XML response from server');
                                                }

                                                var instructorName = getXmlValue(xmlDoc, 'instructorName');
                                                if (!instructorName || instructorName === 'Not available') {
                                                    throw new Error('Instructor data not found');
                                                }

                                                document.getElementById('performanceInstructorName').textContent = instructorName;

                                                // Store performance data for charts
                                                currentPerformanceData = xmlDoc;

                                                // Update performance metrics
                                                document.getElementById('perfOverallRating').textContent = getXmlValue(xmlDoc, 'overallRating');
                                                document.getElementById('perfTotalClasses').textContent = getXmlValue(xmlDoc, 'totalClasses');
                                                document.getElementById('perfCancelled').textContent = getXmlValue(xmlDoc, 'cancelled');
                                                document.getElementById('perfCompletion').textContent = getXmlValue(xmlDoc, 'completion');

                                                // Show modal first
                                                document.getElementById('performanceModal').classList.remove('hidden');

                                                // Update charts with current period
                                                setTimeout(function () {
                                                    updateChartsWithPeriod();
                                                }, 100);
                                            })
                                            .catch(function (error) {
                                                console.error('Error loading performance:', error);
                                                alert('Error loading performance data: ' + error.message);
                                            });
                                }

                                // NEW: Update charts based on period
                                function updateChartsWithPeriod() {
                                    if (!currentPerformanceData)
                                        return;
                                    updateCharts(currentPerformanceData);
                                }

                                function closePerformance() {
                                    document.getElementById('performanceModal').classList.add('hidden');
                                    currentPerformanceData = null;
                                }

                                // View certification
                                function viewCertification() {
                                    if (!currentInstructorId) {
                                        alert('No instructor selected');
                                        return;
                                    }

                                    var certPath = currentCertificationPath;

                                    if (!certPath || certPath === 'Not available' || certPath === '' || certPath.includes('dummy.pdf')) {
                                        certPath = '../certifications/instructor/dummy.pdf';
                                        document.getElementById('certModalTitle').textContent = 'No Certification Available';
                                    } else {
                                        document.getElementById('certModalTitle').textContent = 'Certification Document';
                                    }

                                    document.getElementById('certFrame').src = certPath;
                                    document.getElementById('certModal').classList.remove('hidden');
                                }

                                function closeCert() {
                                    document.getElementById('certModal').classList.add('hidden');
                                    document.getElementById('certFrame').src = '';
                                    currentCertificationPath = '';
                                }

                                // PDF Preview functions
                                function showPDFPreview(pdfBlob, instructorName) {
                                    if (!pdfBlob) {
                                        alert('Failed to generate PDF');
                                        return;
                                    }

                                    var blobURL = URL.createObjectURL(pdfBlob);

                                    document.getElementById('pdfPreviewTitle').textContent = 'Preview: ' + instructorName + ' Performance Report';
                                    document.getElementById('pdfPreviewFrame').src = blobURL;

                                    var currentTime = new Date();
                                    var timeString = currentTime.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});
                                    var dateString = currentTime.toLocaleDateString();
                                    document.getElementById('pdfGenerationTime').textContent = dateString + ' ' + timeString;

                                    var downloadBtn = document.getElementById('pdfDownloadBtn');
                                    var currentDate = new Date();
                                    var fileName = 'Instructor_Performance_Report_' +
                                            instructorName.replace(/\s+/g, '_') + '_' +
                                            currentDate.getFullYear() + '-' +
                                            (currentDate.getMonth() + 1).toString().padStart(2, '0') + '-' +
                                            currentDate.getDate().toString().padStart(2, '0') + '.pdf';

                                    downloadBtn.onclick = function () {
                                        var link = document.createElement('a');
                                        link.href = blobURL;
                                        link.download = fileName;
                                        document.body.appendChild(link);
                                        link.click();
                                        document.body.removeChild(link);
                                    };

                                    document.getElementById('pdfPreviewModal').classList.remove('hidden');
                                }

                                function closePDFPreview() {
                                    document.getElementById('pdfPreviewModal').classList.add('hidden');

                                    var iframe = document.getElementById('pdfPreviewFrame');
                                    if (iframe.src && iframe.src.startsWith('blob:')) {
                                        URL.revokeObjectURL(iframe.src);
                                    }
                                    iframe.src = '';
                                }

                                // Activate/Deactivate functions
                                function toggleActivateInstructor(instructorId) {
                                    currentInstructorId = instructorId;

                                    var instructor = null;
                                    for (var i = 0; i < allInstructors.length; i++) {
                                        if (allInstructors[i].id == instructorId) {
                                            instructor = allInstructors[i];
                                            break;
                                        }
                                    }

                                    if (!instructor) {
                                        alert('Instructor not found');
                                        return;
                                    }

                                    if (instructor.status === 'active') {
                                        // Check if instructor has assigned classes
                                        checkInstructorClasses(instructorId, function (hasClasses) {
                                            showDeactivateConfirmation(instructorId, instructor.name, hasClasses);
                                        });
                                    } else {
                                        // Activate mode
                                        var modalIcon = document.getElementById('modalIcon');
                                        var modalTitle = document.getElementById('modalTitle');
                                        var modalText = document.getElementById('modalText');
                                        var confirmButton = document.getElementById('confirmButton');

                                        modalIcon.innerHTML = '<svg class="w-6 h-6 text-successTextDark" fill="currentColor" viewBox="0 0 20 20">' +
                                                '<path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>' +
                                                '</svg>';
                                        modalIcon.className = 'flex items-center justify-center w-12 h-12 mx-auto mb-4 rounded-full bg-successBg';

                                        modalTitle.textContent = 'Activate Instructor?';
                                        modalText.textContent = 'Are you sure you want to activate ' + instructor.name + '? They will be able to access the system and be assigned to new classes.';

                                        confirmButton.textContent = 'Yes, Activate';
                                        confirmButton.className = 'px-4 py-2 bg-teal text-whitePure rounded-lg hover:bg-tealHover transition-colors';

                                        document.getElementById('activateDeactivateModal').classList.remove('hidden');
                                    }
                                }

                                function closeActivateDeactivate() {
                                    document.getElementById('activateDeactivateModal').classList.add('hidden');
                                    currentInstructorId = null;
                                }

                                function confirmActivateDeactivate() {
                                    if (!currentInstructorId)
                                        return;

                                    var instructor = null;
                                    for (var i = 0; i < allInstructors.length; i++) {
                                        if (allInstructors[i].id == currentInstructorId) {
                                            instructor = allInstructors[i];
                                            break;
                                        }
                                    }

                                    if (!instructor) {
                                        alert('Instructor not found');
                                        closeActivateDeactivate();
                                        return;
                                    }

                                    var newStatus = instructor.status === 'active' ? 'inactive' : 'active';

                                    fetch('monitor-instructor', {
                                        method: 'POST',
                                        body: new URLSearchParams({
                                            action: 'toggleStatus',
                                            id: currentInstructorId,
                                            newStatus: newStatus
                                        }),
                                        headers: {
                                            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                                        }
                                    })
                                            .then(function (response) {
                                                if (!response.ok) {
                                                    return response.text().then(function (text) {
                                                        throw new Error('Server error: ' + response.status);
                                                    });
                                                }
                                                return response.text();
                                            })
                                            .then(function (responseText) {
                                                var parser = new DOMParser();
                                                var xmlDoc = parser.parseFromString(responseText, 'text/xml');

                                                var result = getXmlValue(xmlDoc, 'result');
                                                var message = getXmlValue(xmlDoc, 'message');

                                                if (result === 'success') {
                                                    instructor.status = newStatus;
                                                    updateInstructorRow(instructor);
                                                    loadStats();
                                                    alert(message || 'Status updated successfully');
                                                    closeActivateDeactivate();
                                                } else {
                                                    alert('Error: ' + (message || 'Failed to update status'));
                                                    closeActivateDeactivate();
                                                }
                                            })
                                            .catch(function (error) {
                                                console.error('Error toggling status:', error);
                                                alert('Error updating instructor status: ' + error.message);
                                                closeActivateDeactivate();
                                            });
                                }

                                function updateInstructorRow(instructor) {
                                    var tableBody = document.getElementById('instructorTableBody');
                                    var rows = tableBody.getElementsByTagName('tr');

                                    for (var i = 0; i < rows.length; i++) {
                                        var row = rows[i];
                                        var cells = row.getElementsByTagName('td');

                                        if (cells.length > 0) {
                                            var nameCell = cells[0];
                                            var instructorName = nameCell.querySelector('.text-sm.font-medium') ? nameCell.querySelector('.text-sm.font-medium').textContent : '';

                                            if (instructorName === instructor.name) {
                                                var statusCell = cells[3];
                                                if (instructor.status === 'active') {
                                                    statusCell.innerHTML = '<span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-successBg text-successTextDark">Active</span>';
                                                } else {
                                                    statusCell.innerHTML = '<span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-dangerBg text-dangerText">Inactive</span>';
                                                }

                                                var actionCell = cells[4];
                                                var actionButtonText = instructor.status === 'active' ? 'Deactivate' : 'Activate';
                                                var actionButtonClass = instructor.status === 'active' ? 'text-dusty hover:text-dustyHover' : 'text-teal hover:text-tealHover';
                                                var actionButtonBorder = instructor.status === 'active' ? 'border-dusty' : 'border-teal';

                                                actionCell.innerHTML =
                                                        '<button onclick="showDetails(' + instructor.id + ')" class="text-teal hover:text-tealHover mr-3 px-3 py-1 rounded border border-teal hover:bg-teal/5 transition-colors">View Details</button>' +
                                                        '<button onclick="toggleActivateInstructor(' + instructor.id + ')" class="' + actionButtonClass + ' px-3 py-1 rounded border ' + actionButtonBorder + ' hover:bg-' + (instructor.status === 'active' ? 'dusty' : 'teal') + '/5 transition-colors">' +
                                                        actionButtonText +
                                                        '</button>';

                                                break;
                                            }
                                        }
                                    }

                                    for (var j = 0; j < allInstructors.length; j++) {
                                        if (allInstructors[j].id == instructor.id) {
                                            allInstructors[j].status = instructor.status;
                                            break;
                                        }
                                    }
                                }

                                // Check if instructor has classes
                                function checkInstructorClasses(instructorId, callback) {
                                    fetch('monitor-instructor?action=checkClasses&id=' + instructorId)
                                            .then(function (response) {
                                                if (!response.ok)
                                                    throw new Error('Network response was not ok');
                                                return response.text();
                                            })
                                            .then(function (xmlText) {
                                                var parser = new DOMParser();
                                                var xmlDoc = parser.parseFromString(xmlText, 'text/xml');

                                                var hasClasses = xmlDoc.getElementsByTagName('hasClasses')[0].textContent === 'true';
                                                callback(hasClasses);
                                            })
                                            .catch(function (error) {
                                                console.error('Error checking classes:', error);
                                                callback(false);
                                            });
                                }

                                function showDeactivateConfirmation(instructorId, instructorName, hasClasses) {
                                    currentInstructorId = instructorId;

                                    var modalIcon = document.getElementById('modalIcon');
                                    var modalTitle = document.getElementById('modalTitle');
                                    var modalText = document.getElementById('modalText');
                                    var confirmButton = document.getElementById('confirmButton');

                                    if (hasClasses) {
                                        modalIcon.innerHTML = '<svg class="w-6 h-6 text-warningText" fill="currentColor" viewBox="0 0 20 20">' +
                                                '<path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>' +
                                                '</svg>';
                                        modalIcon.className = 'flex items-center justify-center w-12 h-12 mx-auto mb-4 rounded-full bg-warningBg';

                                        modalTitle.textContent = 'Deactivate Instructor with Assigned Classes?';
                                        modalText.innerHTML = '<p class="mb-2">Instructor <strong>' + instructorName + '</strong> has assigned classes.</p>' +
                                                '<p class="text-sm">The system will automatically:</p>' +
                                                '<ul class="text-sm list-disc pl-4 mt-1 mb-3">' +
                                                '<li>Withdraw instructor from all assigned classes</li>' +
                                                '<li>Promote relief instructors (if available)</li>' +
                                                '<li>Cancel classes without relief within 24 hours</li>' +
                                                '</ul>' +
                                                '<p class="text-xs text-espresso/50">This action cannot be undone.</p>';

                                        confirmButton.textContent = 'Yes, Deactivate & Process Classes';
                                        confirmButton.className = 'px-4 py-2 bg-dusty text-whitePure rounded-lg hover:bg-dustyHover transition-colors';
                                    } else {
                                        modalIcon.innerHTML = '<svg class="w-6 h-6 text-dangerText" fill="currentColor" viewBox="0 0 20 20">' +
                                                '<path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>' +
                                                '</svg>';
                                        modalIcon.className = 'flex items-center justify-center w-12 h-12 mx-auto mb-4 rounded-full bg-dangerBg';

                                        modalTitle.textContent = 'Deactivate Instructor?';
                                        modalText.textContent = 'Are you sure you want to deactivate ' + instructorName + '? They will no longer be able to access the system or be assigned to new classes.';

                                        confirmButton.textContent = 'Yes, Deactivate';
                                        confirmButton.className = 'px-4 py-2 bg-dusty text-whitePure rounded-lg hover:bg-dustyHover transition-colors';
                                    }

                                    document.getElementById('activateDeactivateModal').classList.remove('hidden');
                                }

                                // Chart functions
                                function updateCharts(xmlDoc) {
                                    if (!xmlDoc)
                                        return;

                                    // Destroy existing charts
                                    for (var key in chartInstances) {
                                        if (chartInstances[key]) {
                                            chartInstances[key].destroy();
                                        }
                                    }

                                    // Get ratings data
                                    var teaching = parseFloat(getXmlValue(xmlDoc, 'teaching')) || 0;
                                    var communication = parseFloat(getXmlValue(xmlDoc, 'communication')) || 0;
                                    var support = parseFloat(getXmlValue(xmlDoc, 'support')) || 0;
                                    var punctuality = parseFloat(getXmlValue(xmlDoc, 'punctuality')) || 0;
                                    var overall = parseFloat(getXmlValue(xmlDoc, 'overallRating')) || 0;

                                    // CHART 1: CATEGORY RATINGS
                                    var categoryCtx = document.getElementById('categoryChart').getContext('2d');
                                    chartInstances.categoryChart = new Chart(categoryCtx, {
                                        type: 'bar',
                                        data: {
                                            labels: ['Teaching Skill', 'Communication', 'Support & Interaction', 'Punctuality', 'Overall'],
                                            datasets: [{
                                                    label: 'Average Rating',
                                                    data: [teaching, communication, support, punctuality, overall],
                                                    backgroundColor: ['#6D9B9B', '#A3C1D6', '#F2D1D1', '#B36D6D', '#557878'],
                                                    borderColor: ['#557878', '#8AA9C4', '#E8BEBE', '#965656', '#3D3434'],
                                                    borderWidth: 1,
                                                    borderRadius: 4
                                                }]
                                        },
                                        options: {
                                            responsive: true,
                                            maintainAspectRatio: false,
                                            scales: {
                                                y: {
                                                    beginAtZero: true,
                                                    max: 5,
                                                    grid: {color: '#EFE1E1'},
                                                    ticks: {color: '#3D3434'}
                                                },
                                                x: {
                                                    grid: {color: '#EFE1E1'},
                                                    ticks: {color: '#3D3434'}
                                                }
                                            },
                                            plugins: {
                                                legend: {display: false},
                                                tooltip: {
                                                    backgroundColor: '#3D3434',
                                                    titleColor: '#FDF8F8',
                                                    bodyColor: '#FDF8F8'
                                                }
                                            }
                                        }
                                    });

                                    // CHART 2: MONTHLY TREND
                                    var trendCtx = document.getElementById('trendChart').getContext('2d');

                                    // Get monthly data from XML
                                    var monthlyElements = xmlDoc.getElementsByTagName('month');
                                    var monthLabels = [];
                                    var ratingData = [];
                                    var totalClassesData = [];

                                    for (var i = 0; i < monthlyElements.length; i++) {
                                        var monthElement = monthlyElements[i];
                                        var monthName = monthElement.getElementsByTagName('name')[0].textContent;
                                        var monthRating = parseFloat(monthElement.getElementsByTagName('rating')[0].textContent) || 0;

                                        monthLabels.push(monthName);
                                        ratingData.push(monthRating);
                                    }

                                    // If no data, show placeholder
                                    if (monthlyElements.length === 0) {
                                        var chartContainer = document.getElementById('trendChart').parentElement;
                                        chartContainer.innerHTML = '<div class="text-center py-8"><p class="text-espresso/60">No data available for selected period</p></div>';
                                    } else {
                                        chartInstances.trendChart = new Chart(trendCtx, {
                                            type: 'line',
                                            data: {
                                                labels: monthLabels,
                                                datasets: [{
                                                        label: 'Average Rating',
                                                        data: ratingData,
                                                        borderColor: '#6D9B9B',
                                                        backgroundColor: 'rgba(109, 155, 155, 0.1)',
                                                        borderWidth: 2,
                                                        fill: true,
                                                        tension: 0.4
                                                    }]
                                            },
                                            options: {
                                                responsive: true,
                                                maintainAspectRatio: false,
                                                scales: {
                                                    y: {
                                                        beginAtZero: true,
                                                        max: 5,
                                                        grid: {color: '#EFE1E1'},
                                                        ticks: {color: '#3D3434'}
                                                    },
                                                    x: {
                                                        grid: {color: '#EFE1E1'},
                                                        ticks: {color: '#3D3434'}
                                                    }
                                                },
                                                plugins: {
                                                    legend: {display: false},
                                                    tooltip: {
                                                        backgroundColor: '#3D3434',
                                                        titleColor: '#FDF8F8',
                                                        bodyColor: '#FDF8F8'
                                                    }
                                                }
                                            }
                                        });
                                    }

                                    // CHART 3: CLASS DISTRIBUTION
                                    var distributionCtx = document.getElementById('distributionChart').getContext('2d');

                                    var totalClasses = parseInt(getXmlValue(xmlDoc, 'totalClasses')) || 0;
                                    var cancelledClasses = parseInt(getXmlValue(xmlDoc, 'cancelled')) || 0;
                                    var completedClasses = totalClasses - cancelledClasses;

                                    if (totalClasses === 0) {
                                        var distContainer = document.getElementById('distributionChart').parentElement;
                                        distContainer.innerHTML = '<div class="text-center py-8"><p class="text-espresso/60">No classes found</p></div>';
                                    } else {
                                        chartInstances.distributionChart = new Chart(distributionCtx, {
                                            type: 'pie',
                                            data: {
                                                labels: ['Completed', 'Cancelled'],
                                                datasets: [{
                                                        data: [completedClasses, cancelledClasses],
                                                        backgroundColor: ['#A5D6A7', '#EF9A9A'],
                                                        borderColor: ['#8BC34A', '#F44336'],
                                                        borderWidth: 2
                                                    }]
                                            },
                                            options: {
                                                responsive: true,
                                                maintainAspectRatio: false,
                                                plugins: {
                                                    legend: {
                                                        position: 'bottom',
                                                        labels: {
                                                            color: '#3D3434',
                                                            padding: 20,
                                                            font: {size: 12}
                                                        }
                                                    },
                                                    tooltip: {
                                                        callbacks: {
                                                            label: function (context) {
                                                                var label = context.label || '';
                                                                var value = context.raw || 0;
                                                                var percentage = Math.round((value / totalClasses) * 100);
                                                                return label + ': ' + value + ' (' + percentage + '%)';
                                                            }
                                                        },
                                                        backgroundColor: '#3D3434',
                                                        titleColor: '#FDF8F8',
                                                        bodyColor: '#FDF8F8'
                                                    }
                                                }
                                            }
                                        });
                                    }

                                    // Update rating breakdown table
                                    updateRatingBreakdownTable(xmlDoc);
                                }

                                function updateRatingBreakdownTable(xmlDoc) {
                                    var tableBody = document.getElementById('ratingBreakdownBody');
                                    tableBody.innerHTML = '';

                                    var categories = [
                                        {name: 'Teaching Skill', avg: getXmlValue(xmlDoc, 'teaching'),
                                            high: getXmlValue(xmlDoc, 'teachingHighest'), low: getXmlValue(xmlDoc, 'teachingLowest')},
                                        {name: 'Communication', avg: getXmlValue(xmlDoc, 'communication'),
                                            high: getXmlValue(xmlDoc, 'communicationHighest'), low: getXmlValue(xmlDoc, 'communicationLowest')},
                                        {name: 'Support & Interaction', avg: getXmlValue(xmlDoc, 'support'),
                                            high: getXmlValue(xmlDoc, 'supportHighest'), low: getXmlValue(xmlDoc, 'supportLowest')},
                                        {name: 'Punctuality', avg: getXmlValue(xmlDoc, 'punctuality'),
                                            high: getXmlValue(xmlDoc, 'punctualityHighest'), low: getXmlValue(xmlDoc, 'punctualityLowest')},
                                        {name: 'Overall', avg: getXmlValue(xmlDoc, 'overallRating'),
                                            high: getXmlValue(xmlDoc, 'overallHighest'), low: getXmlValue(xmlDoc, 'overallLowest')}
                                    ];

                                    for (var i = 0; i < categories.length; i++) {
                                        var cat = categories[i];
                                        var row = document.createElement('tr');
                                        row.className = 'border-b border-blush/30';

                                        var avgRating = parseFloat(cat.avg) || 0;
                                        var ratingClass = 'rating-excellent';
                                        if (avgRating < 3.0)
                                            ratingClass = 'rating-poor';
                                        else if (avgRating < 4.0)
                                            ratingClass = 'rating-good';

                                        row.innerHTML = '<td class="py-3 text-sm text-espresso">' + cat.name + '</td>' +
                                                '<td class="py-3"><span class="px-2 py-1 text-xs rounded-full ' + ratingClass + '">' +
                                                (cat.avg || '0.0') + '</span></td>' +
                                                '<td class="py-3 text-sm text-espresso">' + (cat.high || '-') + '</td>' +
                                                '<td class="py-3 text-sm text-espresso">' + (cat.low || '-') + '</td>';

                                        tableBody.appendChild(row);
                                    }
                                }

                                // Export PDF functions with preview
                                function exportPerformancePDF() {
                                    if (!currentInstructorId)
                                        return;

                                    var instructor = null;
                                    for (var i = 0; i < allInstructors.length; i++) {
                                        if (allInstructors[i].id == currentInstructorId) {
                                            instructor = allInstructors[i];
                                            break;
                                        }
                                    }

                                    if (!instructor) {
                                        alert('Instructor not found');
                                        return;
                                    }

                                    // Fetch detailed data for PDF
                                    fetch('monitor-instructor?action=details&id=' + currentInstructorId)
                                            .then(function (response) {
                                                if (!response.ok)
                                                    throw new Error('Network response was not ok');
                                                return response.text();
                                            })
                                            .then(function (xmlText) {
                                                var parser = new DOMParser();
                                                var xmlDoc = parser.parseFromString(xmlText, 'text/xml');

                                                // Extract data for PDF - FIXED: Use averageAllRatings instead of avgRating
                                                var name = getXmlValue(xmlDoc, 'name');
                                                var email = getXmlValue(xmlDoc, 'email');
                                                var experience = getXmlValue(xmlDoc, 'experience');
                                                var totalClasses = parseInt(getXmlValue(xmlDoc, 'totalClasses')) || 0;
                                                var cancelledClasses = parseInt(getXmlValue(xmlDoc, 'cancelledClasses')) || 0;
                                                // FIX: Use averageAllRatings instead of avgRating
                                                var avgRating = getXmlValue(xmlDoc, 'averageAllRatings') || '0.0';
                                                var feedbackCount = parseInt(getXmlValue(xmlDoc, 'feedbackCount')) || 0;
                                                var completedClasses = totalClasses - cancelledClasses;
                                                var completionRate = totalClasses > 0 ? Math.round((completedClasses / totalClasses) * 100) : 0;

                                                // Create PDF
                                                var pdfBlob = createPerformancePDF(name, email, experience, totalClasses, cancelledClasses,
                                                        completedClasses, avgRating, feedbackCount, completionRate);

                                                // Show preview in modal
                                                showPDFPreview(pdfBlob, name);
                                            })
                                            .catch(function (error) {
                                                console.error('Error loading details for PDF:', error);
                                                alert('Error loading data for PDF export: ' + error.message);
                                            });
                                }

                                function createPerformancePDF(name, email, experience, totalClasses, cancelledClasses,
                                        completedClasses, avgRating, feedbackCount, completionRate) {
                                    try {
                                        if (typeof window.jspdf === 'undefined') {
                                            alert('PDF library not loaded. Please check your internet connection.');
                                            return null;
                                        }

                                        var jsPDF = window.jspdf.jsPDF;
                                        var doc = new jsPDF('p', 'mm', 'a4');

                                        // Set font
                                        doc.setFont("helvetica", "normal");

                                        // --- HEADER ---
                                        doc.setFillColor(179, 109, 109); // Dusty color
                                        doc.rect(0, 0, 210, 30, 'F');

                                        // Title
                                        doc.setTextColor(255, 255, 255);
                                        doc.setFontSize(20);
                                        doc.setFont("helvetica", "bold");
                                        doc.text('SKYLIGHT STUDIO', 105, 15, {align: 'center'});

                                        doc.setFontSize(12);
                                        doc.text('INSTRUCTOR PERFORMANCE REPORT', 105, 22, {align: 'center'});

                                        // --- REPORT INFO ---
                                        doc.setTextColor(61, 52, 52); // Espresso color

                                        var currentDate = new Date();
                                        var monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                                            'July', 'August', 'September', 'October', 'November', 'December'];
                                        var formattedDate = currentDate.getDate() + ' ' + monthNames[currentDate.getMonth()] + ' ' + currentDate.getFullYear();

                                        var hours = currentDate.getHours();
                                        var minutes = currentDate.getMinutes();
                                        var formattedTime = (hours < 10 ? '0' : '') + hours + ':' + (minutes < 10 ? '0' : '') + minutes;

                                        var currentY = 40;

                                        doc.setFontSize(12);
                                        doc.setFont("helvetica", "bold");
                                        doc.text('Instructor Information', 20, currentY);

                                        doc.setFontSize(10);
                                        doc.setFont("helvetica", "normal");
                                        currentY += 8;
                                        doc.text('Name: ' + name, 20, currentY);
                                        doc.text('Report Date: ' + formattedDate, 120, currentY);

                                        currentY += 6;
                                        doc.text('Email: ' + email, 20, currentY);
                                        doc.text('Report Time: ' + formattedTime, 120, currentY);

                                        currentY += 6;
                                        doc.text('Experience: ' + experience, 20, currentY);

                                        currentY += 15;

                                        // --- PERFORMANCE SUMMARY ---
                                        doc.setFont("helvetica", "bold");
                                        doc.setFontSize(12);
                                        doc.text('Performance Summary', 20, currentY);

                                        doc.setDrawColor(242, 209, 209); // Blush color
                                        doc.line(20, currentY + 2, 190, currentY + 2);

                                        currentY += 10;

                                        // Create a simple table for performance metrics
                                        var tableData = [
                                            ['Metric', 'Value'],
                                            ['Total Classes', totalClasses.toString()],
                                            ['Completed Classes', completedClasses.toString()],
                                            ['Cancelled Classes', cancelledClasses.toString()],
                                            ['Completion Rate', completionRate + '%'],
                                            ['Average Rating', avgRating + '/5.0'],
                                            ['Total Feedbacks', feedbackCount.toString()]
                                        ];

                                        // Draw table
                                        doc.setFontSize(10);
                                        var startX = 20;
                                        var startY = currentY;
                                        var cellWidth = 85;
                                        var cellHeight = 8;

                                        for (var i = 0; i < tableData.length; i++) {
                                            for (var j = 0; j < tableData[i].length; j++) {
                                                var x = startX + (j * cellWidth);
                                                var y = startY + (i * cellHeight);

                                                // Draw cell border
                                                doc.setDrawColor(200, 200, 200);
                                                doc.rect(x, y - cellHeight + 2, cellWidth, cellHeight);

                                                // Set text style for header row
                                                if (i === 0) {
                                                    doc.setFont("helvetica", "bold");
                                                    doc.setTextColor(61, 52, 52);
                                                } else {
                                                    doc.setFont("helvetica", "normal");
                                                    if (j === 0) {
                                                        doc.setTextColor(100, 100, 100);
                                                    } else {
                                                        doc.setTextColor(61, 52, 52);
                                                        doc.setFont("helvetica", "bold");
                                                    }
                                                }

                                                // Draw text
                                                doc.text(tableData[i][j], x + 5, y);

                                                // Reset font
                                                doc.setFont("helvetica", "normal");
                                                doc.setTextColor(61, 52, 52);
                                            }
                                        }

                                        currentY += (tableData.length * cellHeight) + 10;

                                        // --- PERFORMANCE ANALYSIS ---
                                        if (totalClasses > 0) {
                                            doc.setFont("helvetica", "bold");
                                            doc.setFontSize(12);
                                            doc.text('Performance Analysis', 20, currentY);
                                            doc.line(20, currentY + 2, 190, currentY + 2);

                                            currentY += 10;
                                            doc.setFontSize(10);
                                            doc.setFont("helvetica", "normal");

                                            // Add analysis
                                            var analysis = '';
                                            var avgRatingNum = parseFloat(avgRating);
                                            if (avgRatingNum >= 4.5) {
                                                analysis = 'Excellent performance with outstanding ratings and high completion rate.';
                                            } else if (avgRatingNum >= 4.0) {
                                                analysis = 'Very good performance with consistent high ratings.';
                                            } else if (avgRatingNum >= 3.0) {
                                                analysis = 'Satisfactory performance with room for improvement in certain areas.';
                                            } else {
                                                analysis = 'Performance needs improvement. Consider additional training and support.';
                                            }

                                            doc.text(analysis, 25, currentY, {maxWidth: 165});
                                            currentY += 15;

                                            // Additional notes
                                            if (cancelledClasses > 0) {
                                                doc.text('Note: ' + cancelledClasses + ' class(es) were cancelled.', 25, currentY);
                                                currentY += 6;
                                            }

                                            if (feedbackCount === 0) {
                                                doc.text('Note: No feedback has been received yet.', 25, currentY);
                                                currentY += 6;
                                            }
                                        }

                                        currentY += 10;

                                        // --- RECOMMENDATIONS ---
                                        doc.setFont("helvetica", "bold");
                                        doc.setFontSize(12);
                                        doc.text('Recommendations', 20, currentY);
                                        doc.line(20, currentY + 2, 190, currentY + 2);

                                        currentY += 10;
                                        doc.setFontSize(10);
                                        doc.setFont("helvetica", "normal");

                                        var recommendations = [];
                                        var avgRatingNum = parseFloat(avgRating);

                                        if (totalClasses === 0) {
                                            recommendations = [
                                                'Assign initial classes to assess teaching capabilities',
                                                'Provide comprehensive orientation and training',
                                                'Monitor performance closely during probation period',
                                                'Schedule regular check-ins for first 3 months'
                                            ];
                                        } else if (avgRatingNum >= 4.0) {
                                            recommendations = [
                                                'Continue current effective teaching methods',
                                                'Consider for advanced or specialized class assignments',
                                                'Potential candidate for mentoring new instructors',
                                                'Recognize achievement in staff meetings'
                                            ];
                                        } else {
                                            recommendations = [
                                                'Review teaching methods and student feedback',
                                                'Schedule performance review meeting within 2 weeks',
                                                'Provide additional training resources as needed',
                                                'Set specific improvement goals for next quarter'
                                            ];
                                        }

                                        for (var j = 0; j < recommendations.length; j++) {
                                            doc.text('• ' + recommendations[j], 25, currentY);
                                            currentY += 6;
                                        }

                                        // --- FOOTER ---
                                        var pageHeight = doc.internal.pageSize.height;
                                        doc.setFontSize(8);
                                        doc.setTextColor(150, 150, 150);
                                        doc.text('Confidential - Skylight Studio Management System', 105, pageHeight - 15, {align: 'center'});
                                        doc.text('Page 1 of 1 - Generated on ' + formattedDate + ' at ' + formattedTime, 105, pageHeight - 10, {align: 'center'});

                                        // Generate PDF as blob
                                        var pdfBlob = doc.output('blob');
                                        return pdfBlob;

                                    } catch (error) {
                                        console.error('Error creating PDF:', error);
                                        alert('Error creating PDF: ' + error.message);
                                        return null;
                                    }
                                }

                                function exportDetailedPDF() {
                                    exportPerformancePDF();
                                }

                                // Close modals on ESC key
                                document.addEventListener('keydown', function (e) {
                                    if (e.key === 'Escape') {
                                        closeDetails();
                                        closePerformance();
                                        closeCert();
                                        closeActivateDeactivate();
                                        closePDFPreview();
                                    }
                                });
        </script>
    </body>
</html>