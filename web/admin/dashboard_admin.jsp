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

    // Get context path
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Admin Dashboard Page</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script src="https://cdn.tailwindcss.com"></script>
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
                            chipTeal: '#6D9B9B'
                        }
                    }
                }
            }

            // Define context path for JavaScript
            var contextPath = '<%= contextPath%>';
        </script>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">
            <div class="w-full bg-whitePure py-6 px-6 md:px-8
                 rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1500px">

                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <h2 class="text-xl font-semibold mb-1 text-espresso">
                        Admin Dashboard Page
                    </h2>
                    <p class="text-sm text-espresso/60">
                        Welcome back, Admin! Here's an overview of your studio management.
                    </p>
                </div>

                <!-- Quick Links Section -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <!-- Schedule Management Card -->
                    <a href="schedule_admin.jsp" 
                       class="bg-whitePure border border-blush rounded-xl p-6 hover:border-dusty hover:shadow-md transition-all duration-300 group relative">
                        <div class="flex items-start justify-between">
                            <div>
                                <div class="w-12 h-12 rounded-lg bg-blush flex items-center justify-center mb-4 group-hover:bg-dusty group-hover:text-whitePure transition-colors">
                                    📅
                                </div>
                                <h3 class="font-semibold text-lg text-espresso mb-2">Schedule Management</h3>
                                <p class="text-sm text-espresso/60">Manage class schedules and timings</p>
                            </div>
                            <span id="todaysClassesBadge" class="bg-dusty text-whitePure text-xs font-semibold px-3 py-1 rounded-full">
                                Loading...
                            </span>
                        </div>
                        <div class="mt-4 pt-4 border-t border-blush text-dusty font-medium text-sm">
                            View schedule →
                        </div>
                    </a>

                    <!-- Instructor Monitor Card -->
                    <a href="monitor_instructor.jsp"
                       class="bg-whitePure border border-blush rounded-xl p-6 hover:border-teal hover:shadow-md transition-all duration-300 group relative">
                        <div class="flex items-start justify-between">
                            <div>
                                <div class="w-12 h-12 rounded-lg bg-tealSoft/30 flex items-center justify-center mb-4 group-hover:bg-teal group-hover:text-whitePure transition-colors">
                                    👤
                                </div>
                                <h3 class="font-semibold text-lg text-espresso mb-2">Monitor Instructor</h3>
                                <p class="text-sm text-espresso/60">Track instructor performance and status</p>
                            </div>
                            <span id="activeInstructorsBadge" class="bg-teal text-whitePure text-xs font-semibold px-3 py-1 rounded-full">
                                Loading...
                            </span>
                        </div>
                        <div class="mt-4 pt-4 border-t border-blush text-teal font-medium text-sm">
                            Monitor instructors →
                        </div>
                    </a>

                    <!-- Registration Review Card -->
                    <a href="review_registration.jsp"
                       class="bg-whitePure border border-blush rounded-xl p-6 hover:border-warningText hover:shadow-md transition-all duration-300 group relative">
                        <div class="flex items-start justify-between">
                            <div>
                                <div class="w-12 h-12 rounded-lg bg-warningBg/50 flex items-center justify-center mb-4 group-hover:bg-warningText group-hover:text-whitePure transition-colors">
                                    📋
                                </div>
                                <h3 class="font-semibold text-lg text-espresso mb-2">Review Registration</h3>
                                <p class="text-sm text-espresso/60">Approve or reject new registrations</p>
                            </div>
                            <span id="pendingRegistrationsBadge" class="bg-warningText text-whitePure text-xs font-semibold px-3 py-1 rounded-full">
                                Loading...
                            </span>
                        </div>
                        <div class="mt-4 pt-4 border-t border-blush text-warningText font-medium text-sm">
                            Review registrations →
                        </div>
                    </a>
                </div>

                <!-- Stats Overview -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                    <!-- Total Active Classes -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-medium text-espresso/70">Active Classes</h3>
                            <span class="text-successTextDark text-sm font-medium flex items-center">
                                This Month
                            </span>
                        </div>
                        <div id="totalActiveClasses" class="text-3xl font-bold text-espresso mb-2">0</div>
                        <p class="text-sm text-espresso/50">Total active classes this month</p>
                    </div>

                    <!-- Total Active Instructors -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-medium text-espresso/70">Active Instructors</h3>
                            <span class="text-successTextDark text-sm font-medium flex items-center">
                                Currently Active
                            </span>
                        </div>
                        <div id="totalActiveInstructors" class="text-3xl font-bold text-espresso mb-2">0</div>
                        <p class="text-sm text-espresso/50">Instructors currently active</p>
                    </div>

                    <!-- Average Class Rating -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-medium text-espresso/70">Avg. Class Rating</h3>
                            <span class="text-dusty text-sm font-medium">This month</span>
                        </div>
                        <div class="flex items-center">
                            <div id="averageRating" class="text-3xl font-bold text-espresso mb-2 mr-3">0.0</div>
                            <div class="flex">
                                <svg class="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                                </svg>
                                <span class="text-sm text-espresso/60 ml-1">/ 5.0</span>
                            </div>
                        </div>
                        <p class="text-sm text-espresso/50">Based on feedbacks</p>
                    </div>

                    <!-- Upcoming Classes Today -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-medium text-espresso/70">Today's Classes</h3>
                            <span class="bg-blush text-dusty text-xs font-semibold px-2 py-1 rounded">
                                Scheduled
                            </span>
                        </div>
                        <div id="todaysClasses" class="text-3xl font-bold text-espresso mb-2">0</div>
                        <p class="text-sm text-espresso/50">Classes scheduled for today</p>
                    </div>
                </div>

                <!-- Charts Section -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
                    <!-- Bar Chart - Monthly Classes -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-6">
                            <h3 class="font-semibold text-lg text-espresso">Monthly Classes Overview</h3>
                            <span class="text-sm text-espresso/50">Last 6 months</span>
                        </div>
                        <div class="h-72">
                            <canvas id="monthlyClassesChart"></canvas>
                        </div>
                    </div>

                    <!-- Pie Chart - Class Type Distribution -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-6">
                            <h3 class="font-semibold text-lg text-espresso">Class Type Distribution</h3>
                            <span class="text-sm text-espresso/50">Current Month</span>
                        </div>
                        <div class="h-72">
                            <canvas id="classTypeChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Top Instructors Section -->
                <div class="bg-whitePure border border-blush rounded-xl p-6">
                    <div class="flex items-center justify-between mb-6">
                        <h3 class="font-semibold text-lg text-espresso">Top Rated Instructors</h3>
                        <a href="monitor_instructor.jsp" class="text-dusty text-sm font-medium hover:text-dustyHover">View all →</a>
                    </div>
                    <div id="topInstructorsContainer" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <!-- Data will be loaded via AJAX -->
                        <div class="flex items-center p-4 border border-blush rounded-lg">
                            <div class="w-14 h-14 rounded-full bg-blush flex items-center justify-center mr-4">
                                <span class="text-dusty font-bold text-lg">--</span>
                            </div>
                            <div class="flex-1">
                                <p class="font-bold text-lg text-espresso">Loading...</p>
                                <p class="text-sm text-espresso/60 mb-2">Loading...</p>
                                <div class="flex items-center">
                                    <div class="flex">
                                        <svg class="w-4 h-4 text-gray-300" fill="currentColor" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                                        </svg>
                                    </div>
                                    <span class="ml-2 font-bold text-dusty">0.0</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </main>

        <jsp:include page="../util/footer.jsp" />
        <jsp:include page="../util/sidebar.jsp" />
        <script src="../util/sidebar.js"></script>

        <script>
            // Chart instances
            var monthlyClassesChart = null;
            var classTypeChart = null;

            // Initialize empty charts
            function initializeCharts() {
                // Monthly Classes Chart (Bar Chart)
                var monthlyCtx = document.getElementById('monthlyClassesChart');
                if (monthlyCtx) {
                    monthlyClassesChart = new Chart(monthlyCtx.getContext('2d'), {
                        type: 'bar',
                        data: {
                            labels: [],
                            datasets: [{
                                    label: 'Number of Classes',
                                    data: [],
                                    backgroundColor: '#B36D6D',
                                    borderColor: '#965656',
                                    borderWidth: 1,
                                    borderRadius: 6,
                                    hoverBackgroundColor: '#965656'
                                }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: {display: false},
                                tooltip: {
                                    backgroundColor: '#3D3434',
                                    titleColor: '#FDF8F8',
                                    bodyColor: '#FDF8F8',
                                    borderColor: '#B36D6D',
                                    borderWidth: 1
                                }
                            },
                            scales: {
                                y: {
                                    beginAtZero: true,
                                    grid: {color: '#EFE1E1'},
                                    ticks: {color: '#3D3434'}
                                },
                                x: {
                                    grid: {display: false},
                                    ticks: {color: '#3D3434'}
                                }
                            }
                        }
                    });
                }

                // Class Type Chart (Pie Chart)
                var classTypeCtx = document.getElementById('classTypeChart');
                if (classTypeCtx) {
                    classTypeChart = new Chart(classTypeCtx.getContext('2d'), {
                        type: 'pie',
                        data: {
                            labels: [],
                            datasets: [{
                                    data: [],
                                    backgroundColor: ['#B36D6D', '#6D9B9B', '#F2D1D1', '#A3C1D6', '#D9C5B2'],
                                    borderColor: '#FDF8F8',
                                    borderWidth: 2,
                                    hoverOffset: 12
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
                                        font: {size: 14}
                                    }
                                },
                                tooltip: {
                                    backgroundColor: '#3D3434',
                                    titleColor: '#FDF8F8',
                                    bodyColor: '#FDF8F8',
                                    callbacks: {
                                        label: function (context) {
                                            var label = context.label || '';
                                            var value = context.raw || 0;
                                            var total = 0;
                                            var data = context.dataset.data;
                                            for (var i = 0; i < data.length; i++) {
                                                total += data[i];
                                            }
                                            var percentage = total > 0 ? Math.round((value / total) * 100) : 0;
                                            return label + ': ' + value + ' classes (' + percentage + '%)';
                                        }
                                    }
                                }
                            }
                        }
                    });
                }
            }

            // Load dashboard data via AJAX
            function loadDashboardData() {
                console.log('Loading dashboard data...');
                console.log('Context path: ' + contextPath);

                var servletUrl = contextPath + '/admin/DashboardAdminServlet';
                console.log('Servlet URL: ' + servletUrl);

                var xhr = new XMLHttpRequest();
                xhr.open('GET', servletUrl, true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.onreadystatechange = function () {
                    if (xhr.readyState === 4) {
                        console.log('Response status: ' + xhr.status);
                        console.log('Response text: ' + xhr.responseText);

                        if (xhr.status === 200) {
                            try {
                                var responseText = xhr.responseText;
                                console.log('Response received:', responseText);

                                // Try to parse JSON
                                var data;
                                try {
                                    data = JSON.parse(responseText);
                                } catch (parseError) {
                                    console.error('JSON parse error:', parseError);
                                    showError('Invalid JSON response from server');
                                    return;
                                }

                                // Check if there's an error
                                if (data.error) {
                                    console.error('Server error:', data.error);
                                    showError('Error: ' + data.error);
                                    return;
                                }

                                updateDashboard(data);
                            } catch (e) {
                                console.error('Error processing response:', e);
                                console.error('Response text:', xhr.responseText);
                                showError('Error loading dashboard data: ' + e.message);
                            }
                        } else if (xhr.status === 404) {
                            showError('Servlet not found (404). Please check server configuration.');
                        } else if (xhr.status === 500) {
                            showError('Server error (500). Please check server logs.');
                        } else {
                            showError('Failed to load dashboard data. Status: ' + xhr.status);
                        }
                    }
                };

                xhr.onerror = function () {
                    console.error('Network error occurred');
                    showError('Network error. Please check your connection.');
                };

                xhr.send();
            }

            // Update dashboard with data
            function updateDashboard(data) {
                console.log('Updating dashboard with data:', data);

                // Update statistics
                if (data.totalActiveClasses !== undefined) {
                    document.getElementById('totalActiveClasses').textContent = data.totalActiveClasses;
                }
                if (data.totalActiveInstructors !== undefined) {
                    document.getElementById('totalActiveInstructors').textContent = data.totalActiveInstructors;
                    document.getElementById('activeInstructorsBadge').textContent = data.totalActiveInstructors + ' active';
                }
                if (data.averageRating !== undefined) {
                    document.getElementById('averageRating').textContent = data.averageRating.toFixed(1);
                }
                if (data.todaysClasses !== undefined) {
                    document.getElementById('todaysClasses').textContent = data.todaysClasses;
                    document.getElementById('todaysClassesBadge').textContent = data.todaysClasses + ' classes today';
                }
                if (data.pendingRegistrations !== undefined) {
                    document.getElementById('pendingRegistrationsBadge').textContent = data.pendingRegistrations + ' pending';
                }

                // Update charts
                if (monthlyClassesChart && data.monthlyClassesData) {
                    monthlyClassesChart.data.labels = data.monthlyClassesData.labels;
                    monthlyClassesChart.data.datasets[0].data = data.monthlyClassesData.data;
                    monthlyClassesChart.update();
                }

                if (classTypeChart && data.classTypeData) {
                    classTypeChart.data.labels = data.classTypeData.labels;
                    classTypeChart.data.datasets[0].data = data.classTypeData.data;

                    // Update colors based on number of data points
                    var colors = ['#B36D6D', '#6D9B9B', '#F2D1D1', '#A3C1D6', '#D9C5B2'];
                    classTypeChart.data.datasets[0].backgroundColor = colors.slice(0, data.classTypeData.labels.length);

                    classTypeChart.update();
                }

                // Update top instructors
                if (data.topInstructors && Array.isArray(data.topInstructors)) {
                    var container = document.getElementById('topInstructorsContainer');
                    if (container) {
                        if (data.topInstructors.length > 0) {
                            container.innerHTML = '';
                            data.topInstructors.forEach(function (instructor) {
                                var instructorHTML = createInstructorCard(instructor);
                                container.innerHTML += instructorHTML;
                            });
                        } else {
                            // Tampilkan pesan jika tidak ada instructor dengan rating
                            container.innerHTML = '<div class="col-span-3 text-center py-8">' +
                                    '<div class="w-16 h-16 rounded-full bg-blush flex items-center justify-center mx-auto mb-4">' +
                                    '<span class="text-dusty text-2xl">👤</span>' +
                                    '</div>' +
                                    '<p class="text-lg font-semibold text-espresso mb-1">No Rated Instructors Yet</p>' +
                                    '<p class="text-sm text-espresso/60">Instructor ratings will appear here once students submit feedback</p>' +
                                    '</div>';
                        }
                    }
                }

            }

            // Create instructor card HTML - PERBAIKAN
            function createInstructorCard(instructor) {
                var hasRating = instructor.hasRating === true;
                var ratingValue = instructor.rating || 0;
                var ratingStars = getRatingStars(ratingValue);

                return '<div class="flex items-center p-4 border border-blush rounded-lg hover:bg-cloud transition-colors">' +
                        '<div class="w-14 h-14 rounded-full bg-blush flex items-center justify-center mr-4">' +
                        '<span class="text-dusty font-bold text-lg">' + (instructor.initials || '??') + '</span>' +
                        '</div>' +
                        '<div class="flex-1">' +
                        '<p class="font-bold text-lg text-espresso">' + (instructor.name || 'No Name') + '</p>' +
                        '<p class="text-sm text-espresso/60 mb-2">' + (instructor.specialization || 'General Instructor') + '</p>' +
                        '<div class="flex items-center">' +
                        (hasRating ?
                                ratingStars + '<span class="ml-2 font-bold text-dusty">' + ratingValue.toFixed(1) + '</span>' :
                                '<span class="text-sm text-espresso/50 italic">No ratings yet</span>'
                                ) +
                        '</div>' +
                        '</div>' +
                        '</div>';
            }

            // Generate rating stars HTML
            function getRatingStars(rating) {
                if (!rating)
                    rating = 0;
                var fullStars = Math.floor(rating);
                var halfStar = rating % 1 >= 0.5;
                var emptyStars = 5 - fullStars - (halfStar ? 1 : 0);

                var starsHTML = '';

                // Full stars
                for (var i = 0; i < fullStars; i++) {
                    starsHTML += '<svg class="w-4 h-4 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">' +
                            '<path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>' +
                            '</svg>';
                }

                // Half star
                if (halfStar) {
                    starsHTML += '<svg class="w-4 h-4 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">' +
                            '<path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>' +
                            '</svg>';
                }

                // Empty stars
                for (var i = 0; i < emptyStars; i++) {
                    starsHTML += '<svg class="w-4 h-4 text-gray-300" fill="currentColor" viewBox="0 0 20 20">' +
                            '<path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>' +
                            '</svg>';
                }

                return '<div class="flex">' + starsHTML + '</div>';
            }

            // Show error message
            function showError(message) {
                console.error(message);
                alert('Dashboard Error: ' + message);
            }

            // Initialize on page load
            window.onload = function () {
                console.log('Dashboard page loaded');
                initializeCharts();
                loadDashboardData();

                // Add hover effects for cards
                var cards = document.querySelectorAll('a[href*=".jsp"]');
                for (var i = 0; i < cards.length; i++) {
                    cards[i].addEventListener('mouseenter', function () {
                        this.style.transform = 'translateY(-4px)';
                    });
                    cards[i].addEventListener('mouseleave', function () {
                        this.style.transform = 'translateY(0)';
                    });
                }
            };
        </script>
    </body>
</html>