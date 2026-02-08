<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.*" %>
<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%
    // Check if user is instructor
    if (!SessionUtil.checkInstructorAccess(session)) {
        // Always redirect to login with appropriate message
        if (!SessionUtil.isLoggedIn(session)) {
            response.sendRedirect("../general/login.jsp?error=access_denied&message=Please_login_to_access_instructor_pages");
        } else {
            // If logged in but not instructor
            response.sendRedirect("../general/login.jsp?error=instructor_access_required&message=Instructor_privileges_required_to_access_this_page");
        }
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Instructor Schedule</title>

        <!-- Font Inter + Lora -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">

        <!-- FullCalendar CSS -->
        <link href='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css' rel='stylesheet' />

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

                            /* Chips */
                            chipRose: '#FCE4EC',
                            chipSand: '#D9C5B2',
                            chipTeal: '#6D9B9B'
                        }
                    }
                }
            }
        </script>

        <style>
            /* Custom styles for FullCalendar to ensure it stays within container */
            .fc {
                height: 100% !important;
                max-height: 600px;
            }

            .fc-view {
                height: 100% !important;
                max-height: 550px;
                overflow-y: auto !important;
            }

            .fc-daygrid-month-view .fc-daygrid-body {
                min-height: 0 !important;
            }

            .fc-scrollgrid-section-body table {
                height: 100% !important;
            }

            /* Ensure calendar stays responsive */
            .fc-toolbar {
                flex-wrap: wrap !important;
                gap: 0.5rem !important;
            }

            .fc-toolbar-title {
                font-size: 1.25rem !important;
                margin: 0.5rem 0 !important;
            }

            .fc-button-group {
                margin: 0.25rem 0 !important;
            }

            .fc-button {
                padding: 0.375rem 0.75rem !important;
                font-size: 0.875rem !important;
            }

            /* Custom colors for calendar */
            .fc-header-toolbar {
                margin-bottom: 1rem !important;
            }

            .fc-col-header-cell {
                background-color: #F2D1D1 !important;
                color: #3D3434 !important;
                font-weight: 600 !important;
            }

            .fc-day-today {
                background-color: #FDF8F8 !important;
            }

            .fc-button-primary {
                background-color: #6D9B9B !important;
                border-color: #557878 !important;
            }

            .fc-button-primary:hover {
                background-color: #557878 !important;
                border-color: #557878 !important;
            }

            .fc-button-primary:disabled {
                background-color: #A3C1D6 !important;
                border-color: #A3C1D6 !important;
            }

            .fc-button-primary.fc-button-active {
                background-color: #B36D6D !important;
                border-color: #965656 !important;
            }

            .fc-event {
                border-radius: 4px !important;
                border: none !important;
                padding: 2px 4px !important;
                cursor: pointer !important;
            }

            /* Event status colors */
            .fc-event-available {
                background-color: #6D9B9B !important;
                border-color: #557878 !important;
            }

            .fc-event-confirmed {
                background-color: #A5D6A7 !important;
                border-color: #1B5E20 !important;
                color: #1B5E20 !important;
            }

            .fc-event-pending {
                background-color: #FFCC80 !important;
                border-color: #E65100 !important;
                color: #E65100 !important;
            }

            /* Modal styles */
            .modal-overlay {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: rgba(61, 52, 52, 0.7);
                display: flex;
                justify-content: center;
                align-items: center;
                z-index: 1000;
            }

            .modal-content {
                background-color: white;
                border-radius: 12px;
                padding: 2rem;
                max-width: 500px;
                width: 90%;
                max-height: 90vh;
                overflow-y: auto;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
                animation: modalSlideIn 0.3s ease-out;
            }

            @keyframes modalSlideIn {
                from {
                    opacity: 0;
                    transform: translateY(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .status-badge {
                display: inline-block;
                padding: 0.25rem 0.75rem;
                border-radius: 9999px;
                font-size: 0.75rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }

            .status-available {
                background-color: #E8F5E8;
                color: #1B5E20;
            }

            .status-confirmed {
                background-color: #E8F5E8;
                color: #1B5E20;
            }

            .status-pending {
                background-color: #FFF3E0;
                color: #E65100;
            }

            .instructor-info {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                padding: 0.5rem;
                background-color: #F9FAFB;
                border-radius: 8px;
                margin-top: 0.5rem;
            }

            .instructor-avatar {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                background-color: #6D9B9B;
                color: white;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 600;
                font-size: 14px;
            }

            .instructor-details {
                flex: 1;
            }

            .instructor-name {
                font-weight: 600;
                color: #3D3434;
            }

            .instructor-role {
                font-size: 0.75rem;
                color: #6B7280;
            }

            .close-icon {
                position: absolute;
                top: 1rem;
                right: 1rem;
                background: none;
                border: none;
                cursor: pointer;
                color: #6B7280;
                transition: color 0.2s ease;
            }

            .close-icon:hover {
                color: #3D3434;
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <!-- Header -->
        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">
            <div class="w-full bg-whitePure py-6 px-6 md:px-8
                 rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1500px">

                <!-- Header -->
                <div class="mb-6 pb-4 border-b border-espresso/10">
                    <h1 class="text-2xl font-bold text-espresso mb-1">
                        Available Classes
                    </h1>
                    <p class="text-sm text-espresso/60">
                        View available classes and confirm your participation as instructor
                    </p>
                </div>

                <!-- Status Legend -->
                <div class="mb-6 p-4 bg-cloud rounded-lg border border-petal">
                    <h3 class="text-sm font-semibold text-espresso mb-2">Status Legend</h3>
                    <div class="flex flex-wrap gap-4">
                        <div class="flex items-center">
                            <div class="w-3 h-3 rounded-full bg-teal mr-2"></div>
                            <span class="text-sm text-espresso">Available - No instructor assigned</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-3 h-3 rounded-full bg-successBg mr-2"></div>
                            <span class="text-sm text-espresso">Confirmed - You're teaching</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-3 h-3 rounded-full bg-warningBg mr-2"></div>
                            <span class="text-sm text-espresso">Pending - You're in queue as relief</span>
                        </div>
                    </div>
                </div>

                <!-- Calendar Container with fixed height -->
                <div class="flex-1 min-h-0">
                    <div id="calendar-container" class="h-full flex flex-col">
                        <div id="calendar" class="flex-1 min-h-0"></div>
                    </div>
                </div>

                <!-- No Classes Message (Hidden by default) -->
                <div id="noClassesMessage" class="hidden flex flex-col items-center justify-center py-12 text-center">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 text-espresso/30 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    <h3 class="text-xl font-semibold text-espresso/70 mb-2">
                        No available classes
                    </h3>
                    <p class="text-espresso/50 max-w-md">
                        There are no classes available for registration at the moment.
                    </p>
                </div>

                <!-- Footer -->
                <div class="mt-6 pt-4 border-t border-petal text-center text-xs text-espresso/30">
                    Click on any class to view details and confirm your participation as instructor.
                </div>

            </div>

        </main>

        <!-- Class Details Modal -->
        <div id="classModal" class="modal-overlay hidden">
            <div class="modal-content relative">
                <!-- Close Icon (X) at top right -->
                <button onclick="closeModal()" class="close-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>

                <div class="mb-6">
                    <h2 class="text-xl font-bold text-espresso" id="modalClassName"></h2>
                </div>

                <!-- Status Badge -->
                <div class="mb-6">
                    <span id="modalStatusBadge" class="status-badge"></span>
                </div>

                <!-- Class Details -->
                <div class="space-y-4 mb-6">
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Date & Time</h4>
                        <p id="modalDateTime" class="text-espresso"></p>
                    </div>
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Duration</h4>
                        <p id="modalDuration" class="text-espresso"></p>
                    </div>
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Location</h4>
                        <p id="modalLocation" class="text-espresso"></p>
                    </div>

                    <!-- Main Instructor -->
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Main Instructor</h4>
                        <div id="mainInstructorContainer" class="instructor-info">
                            <!-- Dynamic content will be inserted here -->
                        </div>
                    </div>

                    <!-- Relief Instructor -->
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Relief Instructor</h4>
                        <div id="reliefInstructorContainer" class="instructor-info">
                            <!-- Dynamic content will be inserted here -->
                        </div>
                    </div>

                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Description</h4>
                        <p id="modalDescription" class="text-espresso"></p>
                    </div>
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Total Students</h4>
                        <p id="modalCapacity" class="text-espresso"></p>
                    </div>
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1" hidden>Current Students</h4>
                        <p id="modalStudents" class="text-espresso hidden"></p>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div id="actionButtons" class="flex flex-col gap-3">
                    <!-- Confirm Button (shown when there's no main instructor) -->
                    <button id="confirmBtn" onclick="confirmClass()" 
                            class="w-full bg-teal hover:bg-tealHover text-whitePure font-medium py-3 px-4 rounded-lg transition-colors flex items-center justify-center gap-2 hidden">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                        </svg>
                        Confirm
                    </button>

                    <!-- Pending Button (shown when there's a main instructor but no relief instructor) -->
                    <button id="pendingBtn" onclick="requestPending()" 
                            class="w-full bg-warningBg hover:bg-warningText/20 text-warningText font-medium py-3 px-4 rounded-lg transition-colors flex items-center justify-center gap-2 hidden">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd" />
                        </svg>
                        Pending (Queue as Relief)
                    </button>

                    <!-- Withdraw Button (shown for pending/confirmed classes) -->
                    <button id="withdrawBtn" onclick="withdrawClass()" 
                            class="w-full bg-dangerBg hover:bg-dangerText/20 text-dangerText font-medium py-3 px-4 rounded-lg transition-colors flex items-center justify-center gap-2 hidden">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
                        </svg>
                        <span id="withdrawBtnText"></span>
                    </button>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <jsp:include page="../util/footer.jsp" />

        <!-- Sidebar -->
        <jsp:include page="../util/sidebar.jsp" />
        <script src="../util/sidebar.js"></script>

        <!-- FullCalendar JS -->
        <script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js'></script>
        <script>
                        // Store current instructor ID globally
                        const CURRENT_INSTRUCTOR_ID = '<%= SessionUtil.getCurrentInstructorId(session) != null ? SessionUtil.getCurrentInstructorId(session) : ""%>';

                        // Initialize calendar when page loads
                        document.addEventListener('DOMContentLoaded', function () {
                            console.log('Current Instructor ID from session:', CURRENT_INSTRUCTOR_ID);
                            initializeCalendar();
                            highlightCurrentPage();

                            // Close modal when clicking outside
                            document.getElementById('classModal').addEventListener('click', function (e) {
                                if (e.target === this) {
                                    closeModal();
                                }
                            });

                            // Close modal with Escape key
                            document.addEventListener('keydown', function (e) {
                                if (e.key === 'Escape') {
                                    closeModal();
                                }
                            });
                        });

                        function initializeCalendar() {
                            var calendarEl = document.getElementById('calendar');

                            var calendar = new FullCalendar.Calendar(calendarEl, {
                                initialView: 'dayGridMonth',
                                headerToolbar: {
                                    left: 'prev,next today',
                                    center: 'title',
                                    right: 'dayGridMonth,timeGridWeek,timeGridDay'
                                },
                                events: function (fetchInfo, successCallback, failureCallback) {
                                    fetchEventsFromServer(successCallback, failureCallback);
                                },
                                eventClick: function (info) {
                                    showClassDetails(info.event);
                                },
                                eventDisplay: 'block',
                                eventTimeFormat: {
                                    hour: '2-digit',
                                    minute: '2-digit',
                                    hour12: true
                                },
                                height: 'auto',
                                contentHeight: 'auto',
                                aspectRatio: 1.5,
                                handleWindowResize: true,
                                windowResize: function (view) {
                                    calendar.updateSize();
                                },
                                editable: false,
                                buttonText: {
                                    today: 'Today',
                                    month: 'Month',
                                    week: 'Week',
                                    day: 'Day'
                                },
                                views: {
                                    timeGridWeek: {
                                        dayHeaderFormat: {weekday: 'short', day: 'numeric'},
                                        slotMinTime: '06:00:00',
                                        slotMaxTime: '22:00:00',
                                        allDaySlot: false,
                                        eventTimeFormat: {
                                            hour: '2-digit',
                                            minute: '2-digit',
                                            hour12: true
                                        }
                                    },
                                    timeGridDay: {
                                        slotMinTime: '06:00:00',
                                        slotMaxTime: '22:00:00',
                                        allDaySlot: false,
                                        eventTimeFormat: {
                                            hour: '2-digit',
                                            minute: '2-digit',
                                            hour12: true
                                        }
                                    }
                                }
                            });

                            calendar.render();
                            window.calendar = calendar;

                            // Update calendar size after render
                            setTimeout(function () {
                                calendar.updateSize();
                            }, 100);

                            // Update size on window resize
                            window.addEventListener('resize', function () {
                                calendar.updateSize();
                            });
                        }

                        function fetchEventsFromServer(successCallback, failureCallback) {
                            console.log('Fetching events from database via servlet...');

                            fetch('../ClassConfirmationServlet?action=getClasses', {
                                method: 'GET',
                                headers: {
                                    'Accept': 'application/json',
                                    'Cache-Control': 'no-cache'
                                }
                            })
                                    .then(function (response) {
                                        console.log('Response status:', response.status);

                                        if (response.status === 401 || response.status === 403) {
                                            alert('Session expired. Please login again.');
                                            window.location.href = "../general/login.jsp";
                                            return null;
                                        }

                                        if (!response.ok) {
                                            throw new Error('Server returned ' + response.status + ': ' + response.statusText);
                                        }

                                        return response.text().then(function (text) {
                                            console.log('Raw response:', text);
                                            try {
                                                return JSON.parse(text);
                                            } catch (e) {
                                                console.error('Failed to parse JSON:', e);
                                                console.error('Invalid JSON:', text);
                                                throw new Error('Invalid JSON response from server');
                                            }
                                        });
                                    })
                                    .then(function (data) {
                                        if (!data)
                                            return;

                                        console.log('Parsed data:', data);

                                        if (data.error) {
                                            console.error('Server error:', data.error);
                                            alert('Error: ' + data.error);
                                            failureCallback(data.error);
                                            return;
                                        }

                                        if (data.events) {
                                            console.log('Number of events from database:', data.events.length);

                                            // Transform events to FullCalendar format
                                            var events = data.events.map(function (event) {
                                                // Ensure event has proper structure
                                                const classId = event.id || event.classID || 'event_' + Math.random();
                                                const currentInstructorIdNum = parseInt(CURRENT_INSTRUCTOR_ID);

                                                const props = event.extendedProps || {};
                                                const eventStatus = props.status || 'available';

                                                // Determine if event should be shown based on status
                                                let shouldShowEvent = true;

                                                // Hide events that are "unavailable" (both instructors assigned, user not involved)
                                                if (eventStatus === 'unavailable') {
                                                    shouldShowEvent = false;
                                                    console.log('Filtering out class ' + classId + ': Both instructors assigned, user not involved');
                                                }

                                                if (shouldShowEvent) {
                                                    return {
                                                        id: classId,
                                                        title: event.title || event.className || 'Unnamed Class',
                                                        start: event.start,
                                                        end: event.end,
                                                        className: event.className || 'fc-event-available',
                                                        extendedProps: {
                                                            status: eventStatus,
                                                            location: props.location || 'Not specified',
                                                            description: props.description || '',
                                                            capacity: props.capacity || 0,
                                                            currentStudents: props.currentStudents || 0,
                                                            mainInstructor: props.mainInstructor || null,
                                                            reliefInstructor: props.reliefInstructor || null,
                                                            classId: classId,
                                                            classStatus: props.classStatus || 'available'
                                                        }
                                                    };
                                                } else {
                                                    return null;
                                                }
                                            }).filter(function (event) {
                                                return event !== null; // Remove null events
                                            });

                                            successCallback(events);

                                            // Show/hide calendar based on events
                                            if (events.length === 0) {
                                                document.getElementById('calendar-container').classList.add('hidden');
                                                document.getElementById('noClassesMessage').classList.remove('hidden');
                                                console.log('No classes visible for current user');
                                            } else {
                                                document.getElementById('calendar-container').classList.remove('hidden');
                                                document.getElementById('noClassesMessage').classList.add('hidden');
                                                console.log('Calendar loaded with ' + events.length + ' events visible to current user');
                                            }
                                        } else {
                                            console.error('Invalid response format - no events array:', data);
                                            failureCallback('Invalid response format from server');
                                        }
                                    })
                                    .catch(function (error) {
                                        console.error('Error fetching events:', error);
                                        alert('Error loading classes: ' + error.message);
                                        failureCallback(error.message);

                                        // Show no classes message
                                        document.getElementById('calendar-container').classList.add('hidden');
                                        document.getElementById('noClassesMessage').classList.remove('hidden');
                                    });
                        }

                        function showClassDetails(event) {
                            const modal = document.getElementById('classModal');
                            const props = event.extendedProps;

                            // Store event globally for button handlers
                            window.currentEventDetails = props;

                            // Set modal content
                            document.getElementById('modalClassName').textContent = event.title;

                            // Format date and time
                            const startDate = new Date(event.start);
                            const endDate = new Date(event.end);
                            document.getElementById('modalDateTime').textContent =
                                    startDate.toLocaleDateString('en-US', {
                                        weekday: 'long',
                                        year: 'numeric',
                                        month: 'long',
                                        day: 'numeric'
                                    }) + ' • ' +
                                    startDate.toLocaleTimeString('en-US', {hour: '2-digit', minute: '2-digit'}) + ' - ' +
                                    endDate.toLocaleTimeString('en-US', {hour: '2-digit', minute: '2-digit'});

                            // Calculate duration
                            const durationMs = endDate - startDate;
                            const durationHours = Math.floor(durationMs / (1000 * 60 * 60));
                            const durationMinutes = Math.floor((durationMs % (1000 * 60 * 60)) / (1000 * 60));
                            document.getElementById('modalDuration').textContent =
                                    durationHours + 'h ' + durationMinutes + 'min';

                            document.getElementById('modalLocation').textContent = props.location || 'Not specified';
                            document.getElementById('modalDescription').textContent = props.description || 'No description';
                            document.getElementById('modalCapacity').textContent = (props.capacity || 0) + ' students';
                            document.getElementById('modalStudents').textContent = (props.currentStudents || 0) + ' students enrolled';

                            // Set status badge based on user's relationship to class
                            const statusBadge = document.getElementById('modalStatusBadge');
                            let statusText = '';
                            let statusClass = '';

                            const currentInstructorIdNum = parseInt(CURRENT_INSTRUCTOR_ID);
                            const isMainInstructor = props.mainInstructor && parseInt(props.mainInstructor.id) === currentInstructorIdNum;
                            const isReliefInstructor = props.reliefInstructor && parseInt(props.reliefInstructor.id) === currentInstructorIdNum;

                            if (isMainInstructor) {
                                statusText = 'Confirmed (You are Teaching)';
                                statusClass = 'status-confirmed';
                            } else if (isReliefInstructor) {
                                statusText = 'Pending (You are in Relief Queue)';
                                statusClass = 'status-pending';
                            } else if (props.mainInstructor && !props.reliefInstructor) {
                                statusText = 'Available (Relief Position)';
                                statusClass = 'status-available';
                            } else {
                                statusText = 'Available (Main Position)';
                                statusClass = 'status-available';
                            }

                            statusBadge.textContent = statusText;
                            statusBadge.className = 'status-badge ' + statusClass;

                            // Display instructor information
                            displayInstructorInfo('mainInstructorContainer', props.mainInstructor, 'Main Instructor');
                            displayInstructorInfo('reliefInstructorContainer', props.reliefInstructor, 'Relief Instructor');

                            // Show/hide action buttons
                            const confirmBtn = document.getElementById('confirmBtn');
                            const pendingBtn = document.getElementById('pendingBtn');
                            const withdrawBtn = document.getElementById('withdrawBtn');
                            const withdrawBtnText = document.getElementById('withdrawBtnText');

                            // Reset all buttons
                            confirmBtn.classList.add('hidden');
                            pendingBtn.classList.add('hidden');
                            withdrawBtn.classList.add('hidden');

                            console.log('Current user status for this class:', props.status);

                            // LOGIC FOR BUTTON VISIBILITY:
                            // 1. If current user is MAIN instructor
                            if (isMainInstructor) {
                                console.log('User is main instructor - Show WITHDRAW button');
                                withdrawBtn.classList.remove('hidden');
                                withdrawBtnText.textContent = 'Withdraw as Main Instructor';
                            }
                            // 2. If current user is RELIEF instructor
                            else if (isReliefInstructor) {
                                console.log('User is relief instructor - Show WITHDRAW button');
                                withdrawBtn.classList.remove('hidden');
                                withdrawBtnText.textContent = 'Cancel Relief Request';
                            }
                            // 3. If current user is NOT involved in this class
                            else {
                                // 3a. If class has NO instructors
                                if (!props.mainInstructor && !props.reliefInstructor) {
                                    console.log('Class has no instructors - Show CONFIRM button');
                                    confirmBtn.classList.remove('hidden');
                                }
                                // 3b. If class has ONLY main instructor (no relief)
                                else if (props.mainInstructor && !props.reliefInstructor) {
                                    console.log('Class has main instructor but no relief - Show PENDING button');
                                    pendingBtn.classList.remove('hidden');
                                }
                                // Note: Case 3c (both instructors) should never reach here because 
                                // those classes are filtered out in fetchEventsFromServer
                            }

                            // Store class ID in modal for button actions
                            const classId = props.classId || event.id;
                            modal.setAttribute('data-class-id', classId);
                            console.log('Modal class ID set to:', classId);

                            // Show modal
                            modal.classList.remove('hidden');
                            document.body.style.overflow = 'hidden';
                        }

                        function displayInstructorInfo(containerId, instructor, role) {
                            const container = document.getElementById(containerId);
                            container.innerHTML = '';

                            if (!instructor) {
                                container.innerHTML = '<div class="text-center text-espresso/60 py-2">No ' + role.toLowerCase() + ' assigned</div>';
                            } else {
                                const currentInstructorIdNum = parseInt(CURRENT_INSTRUCTOR_ID);
                                const isYou = parseInt(instructor.id) === currentInstructorIdNum;

                                container.innerHTML =
                                        '<div class="instructor-avatar">' + (instructor.initials || getInitials(instructor.name)) + '</div>' +
                                        '<div class="instructor-details">' +
                                        '<div class="instructor-name">' + (instructor.name || 'Unknown Instructor') + '</div>' +
                                        '<div class="instructor-role">' + role + (isYou ? ' (You)' : '') + '</div>' +
                                        '</div>';
                            }
                        }

                        function getInitials(name) {
                            if (!name)
                                return '??';
                            const parts = name.split(' ');
                            if (parts.length >= 2) {
                                return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
                            }
                            return name.substring(0, Math.min(2, name.length)).toUpperCase();
                        }

                        function closeModal() {
                            document.getElementById('classModal').classList.add('hidden');
                            document.body.style.overflow = 'auto';
                            // Clear stored event details
                            window.currentEventDetails = null;
                        }

                        function confirmClass() {
                            const modal = document.getElementById('classModal');
                            const classId = modal.getAttribute('data-class-id');
                            console.log('Confirm button clicked. Class ID from modal:', classId);

                            if (!classId) {
                                alert('Error: Class ID not found. Please try again.');
                                return;
                            }

                            if (confirm('Are you sure you want to confirm as the main instructor for this class?')) {
                                sendActionToServer('confirm', classId);
                            }
                        }

                        function requestPending() {
                            const modal = document.getElementById('classModal');
                            const classId = modal.getAttribute('data-class-id');
                            console.log('Pending button clicked. Class ID from modal:', classId);

                            if (!classId) {
                                alert('Error: Class ID not found. Please try again.');
                                return;
                            }

                            if (confirm('Request to be added as relief instructor for this class?')) {
                                sendActionToServer('requestRelief', classId);
                            }
                        }

                        function withdrawClass() {
                            const modal = document.getElementById('classModal');
                            const classId = modal.getAttribute('data-class-id');
                            console.log('Withdraw button clicked. Class ID from modal:', classId);

                            if (!classId) {
                                alert('Error: Class ID not found. Please try again.');
                                return;
                            }

                            // Check user's role in this class
                            const currentInstructorIdNum = parseInt(CURRENT_INSTRUCTOR_ID);
                            const props = window.currentEventDetails;

                            let message = '';
                            if (props.mainInstructor && parseInt(props.mainInstructor.id) === currentInstructorIdNum) {
                                message = 'Are you sure you want to withdraw as the main instructor? The relief instructor will become the main instructor.';
                            } else if (props.reliefInstructor && parseInt(props.reliefInstructor.id) === currentInstructorIdNum) {
                                message = 'Are you sure you want to cancel your relief request?';
                            } else {
                                message = 'Are you sure you want to withdraw from this class?';
                            }

                            if (confirm(message)) {
                                sendActionToServer('withdraw', classId);
                            }
                        }

                        function sendActionToServer(action, classId) {
                            console.log('Sending ' + action + ' for class ' + classId);

                            // Create URL-encoded data
                            const data = new URLSearchParams();
                            data.append('action', action);
                            data.append('classId', classId);

                            console.log('Sending data:', data.toString());

                            fetch('../ClassConfirmationServlet', {
                                method: 'POST',
                                body: data,
                                headers: {
                                    'Content-Type': 'application/x-www-form-urlencoded',
                                    'Cache-Control': 'no-cache'
                                }
                            })
                                    .then(function (response) {
                                        console.log('Response status:', response.status);
                                        console.log('Response OK:', response.ok);

                                        if (!response.ok) {
                                            // Try to get more details about the error
                                            return response.text().then(function (text) {
                                                console.log('Error response text:', text);
                                                throw new Error('Server returned ' + response.status + ': ' + response.statusText + '. Response: ' + text);
                                            });
                                        }
                                        return response.json();
                                    })
                                    .then(function (data) {
                                        console.log('Response from server:', data);
                                        if (data.success) {
                                            alert(data.message);
                                            closeModal();
                                            // Refresh calendar to show updated data
                                            window.calendar.refetchEvents();
                                        } else {
                                            alert('Error: ' + data.message);
                                        }
                                    })
                                    .catch(function (error) {
                                        console.error('Error:', error);
                                        alert('Server error occurred: ' + error.message);
                                    });
                        }

                        function highlightCurrentPage() {
                            const currentPage = 'schedule_instructor.jsp';
                            const sidebarLinks = document.querySelectorAll('#sidebar a');

                            sidebarLinks.forEach(function (link) {
                                const href = link.getAttribute('href');
                                if (href && href.includes(currentPage)) {
                                    link.classList.add('bg-blush/30', 'text-dusty', 'font-medium');
                                    link.classList.remove('hover:bg-blush/20', 'text-espresso');
                                }
                            });
                        }
        </script>
    </body>
</html>