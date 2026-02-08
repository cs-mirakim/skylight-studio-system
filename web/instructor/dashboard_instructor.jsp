<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%
    // Check if user is instructor
    if (!SessionUtil.checkInstructorAccess(session)) {
        if (!SessionUtil.isLoggedIn(session)) {
            response.sendRedirect("../general/login.jsp?error=access_denied&message=Please_login_to_access_instructor_pages");
        } else {
            response.sendRedirect("../general/login.jsp?error=instructor_access_required&message=Instructor_privileges_required_to_access_this_page");
        }
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Dashboard Instructor Page</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <!-- Icons -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <!-- Tailwind CDN -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Tailwind Custom Palette -->
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {
                            sans: ['Roboto', 'ui-sans-serif', 'system-ui'],
                        },
                        colors: {
                            /* Primary & Background */
                            dusty: '#B36D6D',
                            dustyHover: '#965656',
                            blush: '#F2D1D1',
                            blushHover: '#E8BEBE',
                            cloud: '#FDF8F8',
                            whitePure: '#FFFFFF',
                            petal: '#EFE1E1',
                            /* Text */
                            espresso: '#3D3434',
                            successText: '#1E3A1E',
                            /* Blue Accents */
                            teal: '#6D9B9B',
                            tealSoft: '#A3C1D6',
                            tealHover: '#557878',
                            /* Alerts */
                            successBg: '#A5D6A7',
                            successTextDark: '#1B5E20',
                            warningBg: '#FFCC80',
                            warningText: '#E65100',
                            dangerBg: '#EF9A9A',
                            dangerText: '#B71C1C',
                            infoBg: '#A3C1D6',
                            infoText: '#2C5555',
                            /* Status Colors */
                            activeBg: '#D4EDDA',
                            activeText: '#155724',
                            pendingReliefBg: '#D1ECF1',
                            pendingReliefText: '#0C5460',
                            /* Chart Colors */
                            chartBlue: '#4A90E2',
                            chartGreen: '#50C878',
                            chartOrange: '#FFA500',
                            chartPurple: '#9B59B6'
                        }
                    }
                }
            }
        </script>

        <style>
            @media (max-width: 640px) {
                .mobile-stack { flex-direction: column !important; }
                .mobile-full { width: 100% !important; }
                .mobile-mb-4 { margin-bottom: 1rem !important; }
                .mobile-mb-2 { margin-bottom: 0.5rem !important; }
            }

            .qr-expanded {
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                z-index: 1000;
                background: white;
                border-radius: 16px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                padding: 30px;
                display: none;
                width: 320px;
                text-align: center;
                border: 3px solid #F2D1D1;
            }

            .qr-expanded img {
                width: 200px;
                height: 200px;
                margin: 0 auto 15px;
                border-radius: 8px;
                border: 1px solid #EFE1E1;
                display: block;
            }

            .qr-expanded.show {
                display: block;
                animation: fadeInScale 0.3s ease-out;
            }

            .qr-overlay {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(0, 0, 0, 0.5);
                z-index: 999;
                display: none;
            }

            .qr-overlay.show {
                display: block;
            }

            @keyframes fadeInScale {
                from {
                    opacity: 0;
                    transform: translate(-50%, -50%) scale(0.9);
                }
                to {
                    opacity: 1;
                    transform: translate(-50%, -50%) scale(1);
                }
            }

            .qr-close-btn {
                position: absolute;
                top: 12px;
                right: 12px;
                background: #EFE1E1;
                border: none;
                border-radius: 50%;
                width: 30px;
                height: 30px;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                color: #3D3434;
                font-size: 16px;
                transition: all 0.2s ease;
                z-index: 1001;
            }

            .qr-close-btn:hover {
                background: #F2D1D1;
                color: #B36D6D;
            }

            .week-day-classes {
                display: flex;
                flex-direction: column;
                gap: 0.375rem;
            }

            .week-class-item {
                font-size: 0.75rem;
                padding: 0.375rem;
                border-radius: 6px;
                border-left: 3px solid;
                background: white;
            }

            .week-class-item.confirm {
                border-left-color: #1B5E20;
                background-color: #A5D6A7;
            }

            .week-class-item.pending {
                border-left-color: #E65100;
                background-color: #FFCC80;
            }

            .week-class-time {
                font-size: 0.7rem;
                color: rgba(61, 52, 52, 0.7);
                margin-top: 0.125rem;
            }

            .week-class-title {
                font-weight: 500;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            .loading-spinner {
                display: inline-block;
                width: 20px;
                height: 20px;
                border: 2px solid #f3f3f3;
                border-top: 2px solid #B36D6D;
                border-radius: 50%;
                animation: spin 1s linear infinite;
            }

            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }

            .week-nav-btn {
                transition: all 0.2s ease;
            }

            .week-nav-btn:hover:not(:disabled) {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(179, 109, 109, 0.2);
            }

            .week-nav-btn:disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="py-6 px-4 md:px-8 flex-1 flex flex-col items-center">
            <!-- MAIN CONTAINER -->
            <div class="w-full bg-whitePure rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1500px">

                <!-- Welcome Header (Will be populated via JavaScript) -->
                <div id="welcomeHeader" class="bg-gradient-to-br from-blush to-petal rounded-t-xl py-8 px-6 md:px-8 border-b border-petal">
                    <div class="flex flex-col md:flex-row justify-between items-start md:items-center mobile-stack">
                        <div class="mobile-full mobile-mb-4 md:mb-0">
                            <div class="flex items-center mb-3">
                                <div class="w-16 h-16 rounded-full bg-whitePure border-4 border-whitePure shadow-md flex items-center justify-center mr-4">
                                    <i class="fas fa-user text-dusty text-2xl"></i>
                                </div>
                                <div>
                                    <h1 id="welcomeMessage" class="text-3xl font-bold text-espresso">
                                        Loading...
                                    </h1>
                                    <p id="instructorInfo" class="text-espresso/70 text-sm mt-1">
                                        <i class="fas fa-certificate text-dusty mr-2"></i>
                                        <span id="statusPlaceholder">Loading...</span>
                                    </p>
                                    <div class="flex items-center mt-3 space-x-4">
                                        <span id="monthlyClasses" class="text-sm bg-whitePure/80 px-3 py-1 rounded-full text-espresso">
                                            <i class="fas fa-calendar-check text-dusty mr-2"></i>
                                            Loading...
                                        </span>
                                        <span id="averageRating" class="text-sm bg-whitePure/80 px-3 py-1 rounded-full text-espresso">
                                            <i class="fas fa-star text-yellow-500 mr-2"></i>
                                            Loading...
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Dashboard Content Grid -->
                <div class="p-6 md:p-8 space-y-8 flex-1">
                    <!-- TODAY'S SCHEDULE -->
                    <div class="bg-white rounded-xl border border-petal p-6 shadow-sm hover:shadow-md transition-shadow duration-300">
                        <h2 class="text-xl font-bold text-espresso mb-2 flex items-center">
                            <i class="fas fa-calendar-day text-dusty mr-3"></i>
                            Today's Schedule
                        </h2>
                        <p id="todayDate" class="text-sm text-espresso/60 mb-6">
                            Loading date...
                        </p>

                        <!-- Loading Spinner -->
                        <div id="todayLoading" class="flex items-center justify-center py-8">
                            <div class="loading-spinner mr-3"></div>
                            <span class="text-espresso">Loading today's schedule...</span>
                        </div>

                        <!-- Today's Classes Timeline -->
                        <div id="todayClassesContainer" class="space-y-4 hidden">
                            <!-- Classes will be loaded here via JavaScript -->
                        </div>

                        <!-- No Classes Message -->
                        <div id="noClassesToday" class="hidden text-center py-8 text-espresso/60">
                            <i class="fas fa-calendar-times text-4xl mb-4"></i>
                            <p>No classes scheduled for today</p>
                        </div>
                    </div>

                    <!-- WEEK OVERVIEW -->
                    <div class="bg-white rounded-xl border border-petal p-6 shadow-sm hover:shadow-md transition-shadow duration-300">
                        <div class="flex flex-col md:flex-row items-start md:items-center justify-between mb-6 gap-4">
                            <h2 class="text-xl font-bold text-espresso flex items-center">
                                <i class="fas fa-calendar text-dusty mr-3"></i>
                                Week Overview
                            </h2>

                            <!-- Week Navigation Controls -->
                            <div class="flex items-center gap-3 w-full md:w-auto">
                                <button id="prevWeekBtn" onclick="navigateWeek(-1)" 
                                        class="week-nav-btn flex items-center gap-2 px-4 py-2 bg-dusty text-white rounded-lg hover:bg-dustyHover transition-colors">
                                    <i class="fas fa-chevron-left"></i>
                                    <span class="hidden sm:inline">Previous</span>
                                </button>

                                <div class="flex-1 md:flex-none text-center">
                                    <span id="currentWeekRange" class="text-sm font-medium text-espresso whitespace-nowrap">
                                        Loading...
                                    </span>
                                </div>

                                <button id="nextWeekBtn" onclick="navigateWeek(1)" 
                                        class="week-nav-btn flex items-center gap-2 px-4 py-2 bg-dusty text-white rounded-lg hover:bg-dustyHover transition-colors">
                                    <span class="hidden sm:inline">Next</span>
                                    <i class="fas fa-chevron-right"></i>
                                </button>

                                <button id="todayWeekBtn" onclick="goToCurrentWeek()" 
                                        class="week-nav-btn px-4 py-2 bg-teal text-white rounded-lg hover:bg-tealHover transition-colors whitespace-nowrap">
                                    <i class="fas fa-calendar-day mr-1"></i>
                                    <span class="hidden sm:inline">This Week</span>
                                    <span class="sm:hidden">Today</span>
                                </button>
                            </div>
                        </div>

                        <!-- Loading Spinner -->
                        <div id="weekLoading" class="flex items-center justify-center py-8">
                            <div class="loading-spinner mr-3"></div>
                            <span class="text-espresso">Loading weekly calendar...</span>
                        </div>

                        <!-- Weekly Calendar Grid -->
                        <div id="weekCalendarContainer" class="mb-8 hidden">
                            <!-- Calendar will be loaded here via JavaScript -->
                        </div>

                        <div id="weekSummaryContainer" class="w-full pt-6 border-t border-petal hidden">
                            <h4 class="font-medium text-espresso mb-4">This Week Summary</h4>

                            <!-- Use SAME 7-column grid as calendar -->
                            <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-7 gap-3 w-full">

                                <!-- Total Confirm Class (span 4/7) -->
                                <div class="md:col-span-4 col-span-2 sm:col-span-2">
                                    <div id="confirmedClassesCard" class="text-center p-6 rounded-lg bg-successBg/20 border border-successBg/30 w-full h-full">
                                        <div class="text-2xl font-bold text-successTextDark">0</div>
                                        <div class="text-sm text-espresso/70 mt-1">Total Confirm Class</div>
                                    </div>
                                </div>

                                <!-- Pending Relief (span 3/7) -->
                                <div class="md:col-span-3 col-span-2 sm:col-span-1">
                                    <div id="pendingClassesCard" class="text-center p-6 rounded-lg bg-warningBg/20 border border-warningBg/30 w-full h-full">
                                        <div class="text-2xl font-bold text-warningText">0</div>
                                        <div class="text-sm text-espresso/70 mt-1">Pending Relief</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- QR Code Modal (Dynamically created) -->
        <div id="qrModalContainer"></div>

        <jsp:include page="../util/footer.jsp" />
        <jsp:include page="../util/sidebar.jsp" />
        <script src="../util/sidebar.js"></script>

        <script>
                                    // Global variables for week navigation
                                    let currentWeekStart = null;
                                    let currentWeekEnd = null;

                                    document.addEventListener('DOMContentLoaded', function () {
                                        // Initialize dashboard
                                        loadDashboardData();
                                    });

                                    async function loadDashboardData() {
                                        try {
                                            // Show loading states
                                            document.getElementById('todayLoading').classList.remove('hidden');
                                            document.getElementById('weekLoading').classList.remove('hidden');

                                            // Load instructor data
                                            await loadInstructorInfo();

                                            // Load today's schedule
                                            await loadTodaySchedule();

                                            // Load weekly overview (current week by default)
                                            await loadWeekOverview();

                                        } catch (error) {
                                            console.error('Error loading dashboard:', error);
                                            alert('Failed to load dashboard data. Please refresh the page.');
                                        }
                                    }

                                    async function loadInstructorInfo() {
                                        try {
                                            const response = await fetch('../DashboardInstructorServlet?action=getInstructorInfo');
                                            if (!response.ok)
                                                throw new Error('Network response was not ok');

                                            const data = await response.json();

                                            if (data.success) {
                                                const instructor = data.data.instructor;
                                                const stats = data.data.stats;

                                                const welcomeMessage = 'Welcome, <span class="text-dusty">' + instructor.name + '</span>!';
                                                document.getElementById('welcomeMessage').innerHTML = welcomeMessage;

                                                const statusText = (instructor.status === 'active') ? 'Active' : 'Inactive';
                                                const instructorInfoText = statusText + ' • Since ' + instructor.joinedYear;
                                                document.getElementById('statusPlaceholder').innerHTML = instructorInfoText;

                                                // Store instructor ID globally for QR modal
                                                window.currentInstructorId = instructor.instructorID;

                                                // Update monthly classes
                                                document.getElementById('monthlyClasses').innerHTML =
                                                        '<i class="fas fa-calendar-check text-dusty mr-2"></i>' + stats.monthlyClassCount + ' Classes This Month';

                                                // Update average rating
                                                document.getElementById('averageRating').innerHTML =
                                                        '<i class="fas fa-star text-yellow-500 mr-2"></i>' + stats.overallRating.toFixed(1) + ' Avg Rating';
                                            }
                                        } catch (error) {
                                            console.error('Error loading instructor info:', error);
                                            document.getElementById('welcomeMessage').textContent = 'Error loading data';
                                        }
                                    }

                                    async function loadTodaySchedule() {
                                        try {
                                            const response = await fetch('../DashboardInstructorServlet?action=getTodaySchedule');
                                            if (!response.ok)
                                                throw new Error('Network response was not ok');

                                            const data = await response.json();

                                            if (data.success) {
                                                // Hide loading
                                                document.getElementById('todayLoading').classList.add('hidden');

                                                const todayData = data.data;

                                                // Update date
                                                document.getElementById('todayDate').textContent =
                                                        todayData.formattedDate + ' • You have ' + todayData.todayClassesCount + ' classes today';

                                                if (todayData.todayClasses.length === 0) {
                                                    // Show no classes message
                                                    document.getElementById('noClassesToday').classList.remove('hidden');
                                                    document.getElementById('todayClassesContainer').classList.add('hidden');
                                                } else {
                                                    // Show classes container
                                                    document.getElementById('noClassesToday').classList.add('hidden');
                                                    document.getElementById('todayClassesContainer').classList.remove('hidden');

                                                    // Render today's classes
                                                    renderTodayClasses(todayData.todayClasses);
                                                }
                                            }
                                        } catch (error) {
                                            console.error('Error loading today schedule:', error);
                                            document.getElementById('todayLoading').innerHTML =
                                                    '<span class="text-dangerText">Error loading schedule</span>';
                                        }
                                    }

                                    function renderTodayClasses(classes) {
                                        const container = document.getElementById('todayClassesContainer');
                                        container.innerHTML = '';

                                        classes.forEach((classData, index) => {
                                            const qrPath = classData.qrcodeFilePath || '../qr_codes/dummy.png';
                                            const statusClass = (classData.status === 'confirmed') ? 'text-successTextDark' : 'text-warningText';
                                            const statusText = (classData.status === 'confirmed') ? 'Confirmed' : 'Pending Relief';

                                            // Format time
                                            const startTime = new Date('1970-01-01T' + classData.classStartTime);
                                            const endTime = new Date('1970-01-01T' + classData.classEndTime);
                                            const startTimeStr = startTime.toLocaleTimeString('en-US', {hour: 'numeric', minute: '2-digit'});

                                            // Calculate duration
                                            const durationMs = endTime - startTime;
                                            const hours = Math.floor(durationMs / (1000 * 60 * 60));
                                            const minutes = Math.floor((durationMs % (1000 * 60 * 60)) / (1000 * 60));
                                            const duration = hours > 0 ? hours + ' hrs ' + minutes + ' mins' : minutes + ' mins';

                                            const classHTML =
                                                    '<div class="flex items-center p-4 rounded-lg border border-blush bg-cloud/30 hover:border-dusty/30 transition-colors duration-200">' +
                                                    '<div class="w-20 text-center flex-shrink-0">' +
                                                    '<div class="text-lg font-bold text-dusty">' +
                                                    startTimeStr +
                                                    '</div>' +
                                                    '<div class="text-xs text-espresso/60">' +
                                                    duration +
                                                    '</div>' +
                                                    '</div>' +
                                                    '<div class="flex-1 ml-6">' +
                                                    '<div class="flex justify-between items-start mobile-stack">' +
                                                    '<div class="mobile-full mobile-mb-2 md:mb-0">' +
                                                    '<h3 class="font-semibold text-espresso text-lg">' + escapeHtml(classData.className) + '</h3>' +
                                                    '<p class="text-sm text-espresso/70 mt-1">' +
                                                    '<i class="fas fa-map-marker-alt mr-2 text-dusty"></i>' +
                                                    escapeHtml(classData.location) + ' • ' +
                                                    '<span class="font-medium ' + statusClass + '">' +
                                                    statusText +
                                                    '</span>' +
                                                    '</p>' +
                                                    '</div>' +
                                                    '<div class="flex items-center space-x-3 flex-shrink-0">' +
                                                    '<div class="relative">' +
                                                    '<div class="w-14 h-14 bg-gray-50 border-2 border-dashed border-dusty rounded-lg flex items-center justify-center cursor-pointer hover:bg-blush transition-colors duration-200"' +
                                                    ' onclick="showQRModal(\'' + escapeHtml(qrPath) + '\', \'' +
                                                    escapeHtml(classData.className) + '\', \'' +
                                                    escapeHtml(startTimeStr) + '\', \'' +
                                                    escapeHtml(classData.location) + '\', ' +
                                                    classData.classID + ')">' +
                                                    '<i class="fas fa-qrcode text-dusty text-xl"></i>' +
                                                    '</div>' +
                                                    '</div>' +
                                                    '</div>' +
                                                    '</div>' +
                                                    '<div class="mt-3 flex items-center text-sm text-espresso/60">' +
                                                    '<span class="mr-4">' +
                                                    '<i class="fas fa-user mr-1"></i>' + escapeHtml(classData.instructorName) +
                                                    '</span>' +
                                                    '<span>' +
                                                    '<i class="fas fa-chart-bar mr-1"></i>Avg. Rating: ' +
                                                    (classData.averageRating ? classData.averageRating.toFixed(1) : 'N/A') + '/5' +
                                                    '</span>' +
                                                    '</div>' +
                                                    '</div>' +
                                                    '</div>';

                                            container.innerHTML += classHTML;
                                        });
                                    }

                                    async function loadWeekOverview(weekStart = null, weekEnd = null) {
                                        try {
                                            // Show loading
                                            document.getElementById('weekLoading').classList.remove('hidden');
                                            document.getElementById('weekCalendarContainer').classList.add('hidden');
                                            document.getElementById('weekSummaryContainer').classList.add('hidden');

                                            let url = '../DashboardInstructorServlet?action=getWeekOverview';

                                            // Add week parameters if provided
                                            if (weekStart && weekEnd) {
                                                url += '&weekStart=' + weekStart + '&weekEnd=' + weekEnd;
                                            }

                                            const response = await fetch(url);
                                            if (!response.ok)
                                                throw new Error('Network response was not ok');

                                            const data = await response.json();

                                            if (data.success) {
                                                // Hide loading
                                                document.getElementById('weekLoading').classList.add('hidden');

                                                const weekData = data.data;

                                                // Store current week dates
                                                currentWeekStart = weekData.weekStart;
                                                currentWeekEnd = weekData.weekEnd;

                                                // Update week range
                                                document.getElementById('currentWeekRange').textContent = weekData.weekRange;

                                                // Show containers
                                                document.getElementById('weekCalendarContainer').classList.remove('hidden');
                                                document.getElementById('weekSummaryContainer').classList.remove('hidden');

                                                // Render calendar
                                                renderWeekCalendar(weekData.weeklyCalendar, weekData.weekStart, weekData.weekEnd);

                                                // Update summary cards
                                                document.querySelector('#confirmedClassesCard .text-2xl').textContent =
                                                        weekData.weeklyStats.confirmed || 0;
                                                document.querySelector('#pendingClassesCard .text-2xl').textContent =
                                                        weekData.weeklyStats.pending || 0;

                                                // Update button states
                                                updateWeekNavigationButtons();
                                            }
                                        } catch (error) {
                                            console.error('Error loading week overview:', error);
                                            document.getElementById('weekLoading').innerHTML =
                                                    '<span class="text-dangerText">Error loading weekly data</span>';
                                    }
                                    }

                                    function navigateWeek(offset) {
                                        if (!currentWeekStart || !currentWeekEnd) {
                                            console.error('Current week dates not set');
                                            return;
                                        }

                                        // Parse current week dates
                                        const startDate = new Date(currentWeekStart);
                                        const endDate = new Date(currentWeekEnd);

                                        // Calculate new week (offset in weeks)
                                        const daysToAdd = offset * 7;
                                        startDate.setDate(startDate.getDate() + daysToAdd);
                                        endDate.setDate(endDate.getDate() + daysToAdd);

                                        // Format dates as YYYY-MM-DD
                                        const newWeekStart = formatDateToString(startDate);
                                        const newWeekEnd = formatDateToString(endDate);

                                        // Load new week
                                        loadWeekOverview(newWeekStart, newWeekEnd);
                                    }

                                    function goToCurrentWeek() {
                                        // Load current week (no parameters = current week)
                                        loadWeekOverview();
                                    }

                                    function updateWeekNavigationButtons() {
                                        // Check if we're viewing the current week
                                        const today = new Date();
                                        const currentStart = new Date(currentWeekStart);
                                        const currentEnd = new Date(currentWeekEnd);

                                        // Normalize dates to compare (remove time component)
                                        today.setHours(0, 0, 0, 0);
                                        currentStart.setHours(0, 0, 0, 0);
                                        currentEnd.setHours(0, 0, 0, 0);

                                        const isCurrentWeek = today >= currentStart && today <= currentEnd;

                                        // Disable/enable "This Week" button
                                        const todayBtn = document.getElementById('todayWeekBtn');
                                        if (isCurrentWeek) {
                                            todayBtn.disabled = true;
                                            todayBtn.classList.add('opacity-50', 'cursor-not-allowed');
                                        } else {
                                            todayBtn.disabled = false;
                                            todayBtn.classList.remove('opacity-50', 'cursor-not-allowed');
                                        }
                                    }

                                    function formatDateToString(date) {
                                        const year = date.getFullYear();
                                        const month = String(date.getMonth() + 1).padStart(2, '0');
                                        const day = String(date.getDate()).padStart(2, '0');
                                        return year + '-' + month + '-' + day;
                                    }

                                    function renderWeekCalendar(weeklyCalendar, weekStart, weekEnd) {
                                        const container = document.getElementById('weekCalendarContainer');
                                        const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

                                        let calendarHTML = '<div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-7 gap-3">';

                                        // Parse week start and end dates
                                        const startDate = new Date(weekStart);
                                        const today = new Date();
                                        today.setHours(0, 0, 0, 0);

                                        // Generate 7 days
                                        for (let i = 0; i < 7; i++) {
                                            const currentDate = new Date(startDate);
                                            currentDate.setDate(startDate.getDate() + i);

                                            // Use getDay() to get day index (0=Sunday, 1=Monday, etc.)
                                            const dayIndex = currentDate.getDay();
                                            const dayName = dayNames[dayIndex];
                                            const dayKey = dayName + '_' + currentDate.getDate();

                                            const dayClasses = weeklyCalendar[dayKey] || [];
                                            const isToday = currentDate.toDateString() === today.toDateString();

                                            const monthName = currentDate.toLocaleString('default', {month: 'short'});
                                            const dayNumber = currentDate.getDate();

                                            let classesHTML = '';
                                            if (dayClasses.length === 0) {
                                                classesHTML =
                                                        '<div class="text-center text-espresso/40 text-xs py-4">' +
                                                        'No classes' +
                                                        '</div>';
                                            } else {
                                                dayClasses.forEach(classData => {
                                                    const time = new Date('1970-01-01T' + classData.classStartTime);
                                                    const timeStr = time.toLocaleTimeString('en-US', {hour: 'numeric', minute: '2-digit'});
                                                    const statusClass = (classData.status === 'confirmed') ? 'confirm' : 'pending';

                                                    classesHTML +=
                                                            '<div class="week-class-item ' + statusClass + '">' +
                                                            '<div class="week-class-title">' + escapeHtml(classData.className) + '</div>' +
                                                            '<div class="week-class-time">' + timeStr + '</div>' +
                                                            '</div>';
                                                });
                                            }

                                            calendarHTML +=
                                                    '<div class="bg-cloud border border-petal rounded-lg p-4 min-h-[140px] hover:border-dusty/30 transition-colors cursor-pointer ' +
                                                    (isToday ? 'bg-gradient-to-br from-blush to-petal/50 border-dusty' : '') + '"' +
                                                    ' onclick="showDayClasses(\'' + dayName + '\', ' + dayNumber + ', ' + dayClasses.length + ')">' +
                                                    '<div class="flex justify-between items-center mb-3 pb-2 border-b border-petal">' +
                                                    '<span class="font-semibold text-espresso ' + (isToday ? 'text-dusty' : '') + '">' +
                                                    dayName +
                                                    '</span>' +
                                                    '<span class="text-sm ' + (isToday ? 'bg-dusty text-white' : 'bg-gray-100 text-espresso/70') + ' px-2 py-1 rounded">' +
                                                    monthName + ' ' + dayNumber +
                                                    '</span>' +
                                                    '</div>' +
                                                    '<div class="week-day-classes">' +
                                                    classesHTML +
                                                    '</div>' +
                                                    '</div>';
                                        }

                                        calendarHTML += '</div>';
                                        container.innerHTML = calendarHTML;
                                    }

                                    function showQRModal(qrPath, className, time, location, classId) {
                                        console.log("QR Modal called:", {qrPath, className, classId});

                                        const instructorId = window.currentInstructorId || '';

                                        // Clear existing modal first
                                        closeQRModal();

                                        // Create overlay
                                        const overlay = document.createElement('div');
                                        overlay.className = 'qr-overlay show';
                                        overlay.id = 'qrOverlay';
                                        overlay.onclick = closeQRModal;

                                        // Create modal content
                                        const modalContent = document.createElement('div');
                                        modalContent.className = 'qr-expanded show';
                                        modalContent.id = 'qrModalContent';

                                        // Modal content HTML
                                        modalContent.innerHTML =
                                                '<button class="qr-close-btn" onclick="closeQRModal()">' +
                                                '<i class="fas fa-times"></i>' +
                                                '</button>' +
                                                '<h4 class="font-semibold text-espresso mb-3">' + escapeHtml(className) + '</h4>' +
                                                '<p class="text-sm text-espresso/70 mb-6">' +
                                                escapeHtml(time) + ' • ' + escapeHtml(location) +
                                                '</p>' +
                                                '<img src="' + escapeHtml(qrPath) + '" alt="QR Code for ' + escapeHtml(className) + '" ' +
                                                'onerror="this.src=\'../qr_codes/dummy.png\'">';

                                        // Add feedback button if we have instructorId
                                        if (instructorId) {
                                            const feedbackBtn = document.createElement('button');
                                            feedbackBtn.className = 'mt-6 w-full bg-dusty text-whitePure py-3 rounded-lg hover:bg-dustyHover transition-colors text-sm font-medium';
                                            feedbackBtn.onclick = function () {
                                                window.location.href = '../instructor/feedback.jsp?classID=' + classId + '&instructorID=' + instructorId;
                                            };
                                            feedbackBtn.innerHTML = '<i class="fas fa-chart-bar mr-2"></i>Submit Feedback';
                                            modalContent.appendChild(feedbackBtn);
                                        }

                                        // Get container or create new one
                                        let container = document.getElementById('qrModalContainer');
                                        if (!container) {
                                            container = document.createElement('div');
                                            container.id = 'qrModalContainer';
                                            document.body.appendChild(container);
                                        }

                                        // Add new modal elements
                                        container.appendChild(overlay);
                                        container.appendChild(modalContent);

                                        console.log("Modal created with QR path:", qrPath);
                                    }

                                    function closeQRModal() {
                                        const container = document.getElementById('qrModalContainer');
                                        if (container) {
                                            container.innerHTML = '';
                                        }
                                    }

                                    function showDayClasses(dayName, date, classCount) {
                                        if (classCount > 0) {
                                            alert(dayName + ', ' + date + ' has ' + classCount + ' class(es).');
                                        }
                                    }

                                    // Helper function to escape HTML
                                    function escapeHtml(text) {
                                        if (!text)
                                            return '';
                                        const div = document.createElement('div');
                                        div.textContent = text;
                                        return div.innerHTML;
                                    }

                                    // Refresh data every 5 minutes
                                    setInterval(loadDashboardData, 5 * 60 * 1000);
        </script>

    </body>
</html>
