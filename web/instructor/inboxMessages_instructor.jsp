<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%@ page import="com.skylightstudio.classmanagement.dao.ClassDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.skylightstudio.classmanagement.model.Class" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Check if user is instructor
    if (!SessionUtil.checkInstructorAccess(session)) {
        // Always redirect to login with appropriate message
        if (!SessionUtil.isLoggedIn(session)) {
            response.sendRedirect(request.getContextPath() + "/general/login.jsp?error=access_denied&message=Please_login_to_access_instructor_pages");
        } else {
            // If logged in but not instructor
            response.sendRedirect(request.getContextPath() + "/general/login.jsp?error=instructor_access_required&message=Instructor_privileges_required_to_access_this_page");
        }
        return;
    }
    
    // Get instructor ID from session
    Integer instructorId = SessionUtil.getCurrentInstructorId(session);
    
    // Initialize variables
    List<Map<String, Object>> notifications = null;
    int totalCount = 0;
    int newClassCount = 0;
    int cancelledCount = 0;
    int waitlistCount = 0;
    int reminderCount = 0;
    int tomorrowCount = 0;
    String error = null;
    String instructorName = SessionUtil.getCurrentInstructorName(session);
    
    // Check if data is already provided by servlet
    Map<String, Object> notificationData = (Map<String, Object>) request.getAttribute("notificationData");
    
    if (notificationData != null) {
        // Data provided by servlet
        notifications = (List<Map<String, Object>>) notificationData.get("allNotifications");
        totalCount = (Integer) notificationData.get("totalCount");
        newClassCount = (Integer) notificationData.getOrDefault("newClassCount", 0);
        cancelledCount = (Integer) notificationData.getOrDefault("cancelledCount", 0);
        waitlistCount = (Integer) notificationData.getOrDefault("waitlistCount", 0);
        reminderCount = (Integer) notificationData.getOrDefault("reminderCount", 0);
        tomorrowCount = (Integer) notificationData.getOrDefault("tomorrowCount", 0);
        error = (String) request.getAttribute("error");
    } else if (instructorId != null) {
        // No data from servlet, fetch directly in JSP
        try {
            ClassDAO classDAO = new ClassDAO();
            notifications = classDAO.getNotificationsForInstructor(instructorId);
            totalCount = notifications.size();
            
            // Count by type
            for (Map<String, Object> notif : notifications) {
                String type = (String) notif.get("type");
                if ("new_class".equals(type)) {
                    newClassCount++;
                } else if ("cancelled".equals(type)) {
                    cancelledCount++;
                } else if ("waitlist".equals(type)) {
                    waitlistCount++;
                } else if ("reminder".equals(type)) {
                    reminderCount++;
                } else if ("tomorrow".equals(type)) {
                    tomorrowCount++;
                }
            }
        } catch (Exception e) {
            error = "Error loading notifications: " + e.getMessage();
            e.printStackTrace();
        }
    }
    
    // For formatting dates
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM d");
    SimpleDateFormat timeFormat = new SimpleDateFormat("h:mm a");
    SimpleDateFormat fullDateFormat = new SimpleDateFormat("MMM d, yyyy");
    
    // Helper function for relative time
    java.util.Date now = new java.util.Date();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Message Page - Instructor</title>

        <!-- Font Inter + Lora -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">

        <!-- Font Awesome for icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

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
                            chipTeal: '#6D9B9B'
                        }
                    }
                }
            }
        </script>
        
        <style>
            .notification-item {
                transition: all 0.3s ease;
            }
            .notification-item:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <!-- Header -->
        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">
            <div class="w-full bg-whitePure py-6 px-6 md:px-8 rounded-xl shadow-sm border border-blush flex-1 flex flex-col" style="max-width:1500px">

                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <h2 class="text-xl font-semibold mb-1 text-espresso">
                        Message for you
                        <% if (instructorName != null) { %>
                            <span class="text-espresso/60">- <%= instructorName %></span>
                        <% } %>
                    </h2>
                    <p class="text-sm text-espresso/60">
                        <% if (totalCount > 0) { %>
                            You have <%= totalCount %> notifications
                        <% } else { %>
                            No new notifications
                        <% } %>
                        <% if (error != null) { %>
                            <span class="text-dangerText"> (Error: <%= error %>)</span>
                        <% } %>
                    </p>
                </div>

                <!-- Display error if any -->
                <% if (error != null && !error.isEmpty()) { %>
                    <div class="mb-6 p-4 bg-dangerBg/20 border border-dangerText/30 rounded-lg">
                        <div class="flex items-start">
                            <i class="fas fa-exclamation-circle text-dangerText mr-3 mt-0.5"></i>
                            <div class="flex-1">
                                <p class="text-dangerText font-medium mb-1">Error loading notifications</p>
                                <p class="text-dangerText/80 text-sm"><%= error %></p>
                            </div>
                        </div>
                    </div>
                <% } %>

                <!-- Notifications Card -->
                <div class="bg-whitePure rounded-xl p-6 border border-blush shadow-sm mb-8">
                    <div class="flex items-center justify-between mb-6">
                        <div class="flex items-center">
                            <div class="p-2 rounded-lg bg-blush/10 mr-3">
                                <i class="fas fa-bell text-dusty text-lg"></i>
                            </div>
                            <div>
                                <h2 class="text-xl font-semibold text-espresso">
                                    Notifications
                                </h2>
                                <p class="text-xs text-espresso/60 mt-1">Stay updated with your class activities</p>
                            </div>
                        </div>
                        <div class="relative">
                            <% if (totalCount > 0) { %>
                                <span class="absolute -top-2 -right-2 bg-dangerText text-whitePure text-xs w-5 h-5 rounded-full flex items-center justify-center">
                                    <%= totalCount %>
                                </span>
                            <% } %>
                        </div>
                    </div>

                    <div class="notification-scroll space-y-3 max-h-80 overflow-y-auto pr-2">
                        <% 
                        if (notifications != null && !notifications.isEmpty()) { 
                            for (Map<String, Object> notification : notifications) {
                                String type = (String) notification.get("type");
                                Class cls = (Class) notification.get("class");
                                String message = (String) notification.get("message");
                                Timestamp timestamp = (Timestamp) notification.get("timestamp");
                                
                                // Determine notification styling based on type
                                String bgClass = "";
                                String borderClass = "";
                                String iconColor = "";
                                String iconClass = "";
                                String badgeText = "";
                                String badgeColor = "";
                                String title = "";
                                
                                // Use if-else instead of switch for Java 7 compatibility
                                if ("new_class".equals(type)) {
                                    bgClass = "bg-infoBg/5";
                                    borderClass = "border-infoBg/20";
                                    iconColor = "text-teal";
                                    iconClass = "fas fa-plus";
                                    badgeText = "Needs confirmation";
                                    badgeColor = "bg-teal/10 text-teal";
                                    title = "New Class Available";
                                } else if ("tomorrow".equals(type)) {
                                    bgClass = "bg-successBg/5";
                                    borderClass = "border-successBg/20";
                                    iconColor = "text-successTextDark";
                                    iconClass = "fas fa-calendar-check";
                                    badgeText = "Tomorrow";
                                    badgeColor = "bg-successTextDark/10 text-successTextDark";
                                    title = "Class Tomorrow";
                                } else if ("reminder".equals(type)) {
                                    bgClass = "bg-blush/10";
                                    borderClass = "border-blush/20";
                                    iconColor = "text-dusty";
                                    iconClass = "fas fa-bell";
                                    badgeText = "Reminder";
                                    badgeColor = "bg-dusty/10 text-dusty";
                                    title = "Class Reminder";
                                } else if ("cancelled".equals(type)) {
                                    bgClass = "bg-dangerBg/5";
                                    borderClass = "border-dangerBg/20";
                                    iconColor = "text-dangerText";
                                    iconClass = "fas fa-times-circle";
                                    badgeText = "Cancelled";
                                    badgeColor = "bg-dangerText/10 text-dangerText";
                                    title = "Class Cancelled";
                                } else if ("waitlist".equals(type)) {
                                    bgClass = "bg-warningBg/5";
                                    borderClass = "border-warningBg/20";
                                    iconColor = "text-warningText";
                                    iconClass = "fas fa-user-clock";
                                    badgeText = "Waitlist";
                                    badgeColor = "bg-warningText/10 text-warningText";
                                    title = "Waitlist Update";
                                }
                                
                                // Calculate relative time
                                String timeAgo = "";
                                if (timestamp != null) {
                                    long diffInMillis = now.getTime() - timestamp.getTime();
                                    long diffInHours = diffInMillis / (60 * 60 * 1000);
                                    long diffInDays = diffInMillis / (24 * 60 * 60 * 1000);
                                    
                                    if (diffInHours < 1) {
                                        long diffInMinutes = diffInMillis / (60 * 1000);
                                        if (diffInMinutes < 1) {
                                            timeAgo = "Just now";
                                        } else {
                                            timeAgo = diffInMinutes + " minutes ago";
                                        }
                                    } else if (diffInHours < 24) {
                                        timeAgo = diffInHours + " hours ago";
                                    } else if (diffInDays < 7) {
                                        timeAgo = diffInDays + " days ago";
                                    } else {
                                        timeAgo = timeFormat.format(timestamp);
                                    }
                                }
                        %>
                        
                        <!-- Dynamic Notification -->
                        <div class="p-4 rounded-lg <%= bgClass %> border <%= borderClass %> notification-item">
                            <div class="flex items-start">
                                <div class="relative mr-3 flex-shrink-0">
                                    <div class="w-10 h-10 rounded-lg <%= bgClass.replace("bg-", "bg-").replace("/5", "/10") %> flex items-center justify-center">
                                        <i class="<%= iconClass %> <%= iconColor %>"></i>
                                    </div>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="flex justify-between items-start">
                                        <div>
                                            <h4 class="text-sm font-semibold text-espresso mb-1">
                                                <%= title %>
                                            </h4>
                                            <p class="text-xs text-espresso/70 mb-2"><%= message %></p>
                                        </div>
                                        <span class="text-xs text-espresso/40 whitespace-nowrap ml-2">
                                            <%= timeAgo %>
                                        </span>
                                    </div>
                                    <% if (cls != null) { %>
                                    <div class="flex flex-wrap items-center gap-2 mt-2">
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full <%= badgeColor %>">
                                            <i class="<%= iconClass %> text-xs mr-1"></i><%= badgeText %>
                                        </span>
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-blush/20 text-espresso/80">
                                            <i class="fas fa-calendar mr-1"></i><%= fullDateFormat.format(cls.getClassDate()) %>
                                        </span>
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-blush/20 text-espresso/80">
                                            <i class="fas fa-clock mr-1"></i><%= timeFormat.format(cls.getClassStartTime()) %> - <%= timeFormat.format(cls.getClassEndTime()) %>
                                        </span>
                                        <% if (cls.getLocation() != null && !cls.getLocation().isEmpty()) { %>
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-blush/20 text-espresso/80">
                                            <i class="fas fa-map-marker-alt mr-1"></i><%= cls.getLocation() %>
                                        </span>
                                        <% } %>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        
                        <% } } else { %>
                        
                        <!-- No Notifications -->
                        <div class="p-8 text-center">
                            <div class="w-16 h-16 mx-auto mb-4 rounded-full bg-blush/20 flex items-center justify-center">
                                <i class="fas fa-bell-slash text-dusty text-2xl"></i>
                            </div>
                            <h3 class="text-lg font-medium text-espresso mb-2">No Notifications</h3>
                            <p class="text-espresso/60 mb-4">You're all caught up! Check back later for updates.</p>
                            <% if (error != null && !error.isEmpty()) { %>
                                <div class="mt-4 p-3 bg-dangerBg/20 rounded-lg">
                                    <p class="text-dangerText text-sm">Error: <%= error %></p>
                                </div>
                            <% } %>
                            <!-- Keep this link to servlet for consistency -->
                            <a href="<%= request.getContextPath() %>/instructor/inboxMessages_instructor.jsp" 
                               class="inline-flex items-center text-sm text-dusty hover:text-dustyHover mt-4">
                                <i class="fas fa-redo mr-2"></i> Refresh
                            </a>
                        </div>
                        
                        <% } %>
                    </div>

                    <!-- View all link -->
                    <div class="mt-6 pt-4 border-t border-blush">
                        <a href="<%= request.getContextPath() %>/instructor/inboxMessages_instructor.jsp" 
                           class="block text-center text-sm text-espresso/70 hover:text-espresso py-2 hover:bg-blush/10 rounded-lg transition-colors">
                            <i class="fas fa-redo mr-2"></i>Refresh notifications
                        </a>
                    </div>
                </div>

                <div class="mt-auto pt-10 text-center text-xs text-espresso/30 italic">
                    Last updated: <%= new java.util.Date() %>
                    <% if (instructorId != null) { %>
                        <br>Instructor ID: <%= instructorId %>
                    <% } %>
                </div>
            </div>
        </main>

        <!-- Footer -->
        <jsp:include page="../util/footer.jsp" />

        <!-- Sidebar -->
        <jsp:include page="../util/sidebar.jsp" />
        <script src="../util/sidebar.js"></script>

        <script>
            // Highlight current page in sidebar
            document.addEventListener('DOMContentLoaded', function () {
                highlightCurrentPage();
                
                // Auto-refresh notifications every 5 minutes
                setInterval(function() {
                    console.log('Auto-refreshing notifications...');
                    window.location.reload();
                }, 300000); // 5 minutes
            });

            function highlightCurrentPage() {
                // Highlight current page in sidebar
                const currentPage = 'inboxMessages_instructor.jsp';
                const sidebarLinks = document.querySelectorAll('#sidebar a');

                sidebarLinks.forEach(link => {
                    const href = link.getAttribute('href');
                    if (href && (href.includes(currentPage) || href.includes('inboxMessages_instructor.jsp'))) {
                        link.classList.add('bg-blush/30', 'text-dusty', 'font-medium');
                        link.classList.remove('hover:bg-blush/20', 'text-espresso');
                    }
                });
            }
        </script>
    </body>
</html>
