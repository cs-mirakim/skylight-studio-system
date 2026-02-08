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
        <title>Admin Class Management Page</title>

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
                            /* Primary & Background */
                            dusty: '#B36D6D',
                            dustyHover: '#8A5252',
                            blush: '#F2D1D1',
                            blushHover: '#E5BCBC',
                            cloud: '#FDF8F8',
                            whitePure: '#FFFFFF',
                            petal: '#EFE1E1',

                            /* Text */
                            espresso: '#3D3434',
                            espressoLight: '#5C4F4F',
                            espressoLighter: '#7A6A6A',

                            /* Blue Accents */
                            teal: '#6D9B9B',
                            tealSoft: '#A3C1D6',
                            tealHover: '#557878',

                            /* Green Accents */
                            sage: '#8AA28A',
                            sageLight: '#A8C1A8',

                            /* Alerts */
                            successBg: '#D4EDDA',
                            successText: '#155724',

                            warningBg: '#FFF3CD',
                            warningText: '#856404',

                            dangerBg: '#F8D7DA',
                            dangerText: '#721C24',

                            infoBg: '#D1ECF1',
                            infoText: '#0C5460',

                            /* Status */
                            activeBg: '#E8F5E9',
                            activeText: '#2E7D32',
                            inactiveBg: '#FFEBEE',
                            inactiveText: '#C62828',
                            autoInactiveBg: '#FFF3CD',
                            autoInactiveText: '#856404',

                            /* Time Status */
                            warningTimeBg: '#FFF3CD',
                            warningTimeText: '#856404',
                            criticalTimeBg: '#F8D7DA',
                            criticalTimeText: '#721C24',
                            safeTimeBg: '#D4EDDA',
                            safeTimeText: '#155724',

                            /* Instructor Status */
                            confirmedBg: '#D4EDDA',
                            confirmedText: '#155724',
                            pendingReliefBg: '#D1ECF1',
                            pendingReliefText: '#0C5460',

                            /* Chips */
                            chipRose: '#FCE4EC',
                            chipSand: '#F5E6D3',
                            chipTeal: '#E0F2F1'
                        }
                    }
                }
            }
        </script>

        <style>
            .modal-backdrop {
                background-color: rgba(61, 52, 52, 0.7);
                backdrop-filter: blur(4px);
            }
            .scrollbar-thin::-webkit-scrollbar {
                width: 6px;
                height: 6px;
            }
            .scrollbar-thin::-webkit-scrollbar-track {
                background: #FDF8F8;
            }
            .scrollbar-thin::-webkit-scrollbar-thumb {
                background: #D9B8B8;
                border-radius: 3px;
            }
            .scrollbar-thin::-webkit-scrollbar-thumb:hover {
                background: #B36D6D;
            }
            .btn-primary {
                background-color: #B36D6D;
                color: white;
            }
            .btn-primary:hover {
                background-color: #8A5252;
            }
            .btn-secondary {
                background-color: #F2D1D1;
                color: #3D3434;
            }
            .btn-secondary:hover {
                background-color: #E5BCBC;
            }
            .btn-accent {
                background-color: #6D9B9B;
                color: white;
            }
            .btn-accent:hover {
                background-color: #557878;
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
                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <div class="flex flex-col md:flex-row md:items-center md:justify-between">
                        <div>
                            <h2 class="text-xl font-semibold mb-1 text-espresso">
                                Admin Class Management Page
                            </h2>
                            <p class="text-sm text-espressoLighter">
                                Manage and schedule all classes for the fitness center
                            </p>
                        </div>
                        <button id="addClassBtn" 
                                class="mt-4 md:mt-0 btn-primary px-6 py-2.5 rounded-lg font-medium transition duration-200 shadow-sm">
                            + Add New Class
                        </button>
                    </div>
                </div>

                <!-- Filter Section -->
                <div class="mb-6 p-4 bg-petal/50 rounded-lg border border-blush">
                    <h3 class="font-medium mb-3 text-espresso">Filter Classes</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                        <!-- Status Filter -->
                        <div>
                            <label class="block text-sm font-medium mb-1 text-espresso">Status</label>
                            <select id="filterStatus" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                <option value="">All Status</option>
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                                <option value="auto-inactive">Auto-Inactive</option>
                            </select>
                        </div>

                        <!-- Date Filter -->
                        <div>
                            <label class="block text-sm font-medium mb-1 text-espresso">Date</label>
                            <input type="date" id="filterDate" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                        </div>

                        <!-- Class Type Filter -->
                        <div>
                            <label class="block text-sm font-medium mb-1 text-espresso">Class Type</label>
                            <select id="filterType" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                <option value="">All Types</option>
                                <option value="mat pilates">Mat Pilates</option>
                                <option value="reformer">Reformer</option>
                            </select>
                        </div>

                        <!-- Class Level Filter -->
                        <div>
                            <label class="block text-sm font-medium mb-1 text-espresso">Class Level</label>
                            <select id="filterLevel" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                <option value="">All Levels</option>
                                <option value="beginner">Beginner</option>
                                <option value="intermediate">Intermediate</option>
                                <option value="advanced">Advanced</option>
                            </select>
                        </div>
                    </div>
                    <div class="flex justify-end mt-4">
                        <button id="applyFilterBtn" class="btn-accent px-5 py-2 rounded-lg font-medium mr-2 shadow-sm">
                            Apply Filters
                        </button>
                        <button id="resetFilterBtn" class="btn-secondary px-5 py-2 rounded-lg font-medium shadow-sm">
                            Reset
                        </button>
                    </div>
                </div>

                <!-- Rules Info Box -->
                <div class="mb-6 p-4 bg-infoBg/30 border border-infoText/20 rounded-lg">
                    <div class="flex justify-between items-start">
                        <div>
                            <h4 class="font-medium text-infoText mb-2">📋 Class Management Rules:</h4>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <h5 class="font-medium text-espresso mb-1">Basic Rules:</h5>
                                    <ul class="text-sm text-espresso space-y-1">
                                        <li>• Classes auto-inactive if no instructor within 24 hours before start</li>
                                        <li>• Cannot set to inactive if <24 hours remaining</li>
                                        <li>• Cannot reactivate if <24 hours remaining</li>
                                        <li>• Delete only allowed for classes without instructors</li>
                                    </ul>
                                </div>
                                <div>
                                    <h5 class="font-medium text-espresso mb-1">Emergency Withdrawal:</h5>
                                    <ul class="text-sm text-espresso space-y-1">
                                        <li>• Only way to withdraw confirmed instructors</li>
                                        <li>• >24 hours: Withdraw instructor, class remains active</li>
                                        <li>• <24 hours with relief: Relief automatically becomes confirmed instructor</li>
                                        <li>• <24 hours no relief: Class cancelled</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Loading Spinner -->
                <div id="loadingSpinner" class="hidden flex items-center justify-center p-8">
                    <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-dusty"></div>
                    <span class="ml-3 text-espresso">Loading classes...</span>
                </div>

                <!-- Classes Table -->
                <div class="flex-1 flex flex-col">
                    <div class="overflow-x-auto scrollbar-thin">
                        <table class="min-w-full divide-y divide-blush/50">
                            <thead>
                                <tr class="bg-petal/80">
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Class Name</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Date & Time</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Time Until Class</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Type & Level</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Instructor</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Status</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">QR Code</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="classesTableBody" class="bg-whitePure divide-y divide-blush/30">
                                <!-- Classes will be loaded here by JavaScript -->
                            </tbody>
                        </table>
                    </div>

                    <!-- No Classes Message -->
                    <div id="noClassesMessage" class="hidden flex-1 flex items-center justify-center p-8">
                        <div class="text-center">
                            <div class="text-espresso/40 mb-2">
                                <svg class="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                </svg>
                            </div>
                            <p class="text-espressoLighter">No classes found. Click "Add New Class" to create one.</p>
                        </div>
                    </div>

                    <!-- Pagination -->
                    <div id="pagination" class="mt-6 flex items-center justify-between border-t border-blush/50 pt-4">
                        <div class="text-sm text-espressoLighter">
                            Showing <span id="startRow">1</span> to <span id="endRow">10</span> of <span id="totalRows">0</span> classes
                        </div>
                        <div class="flex space-x-2">
                            <button id="prevPage" class="px-3 py-1 border border-blush rounded text-espressoLighter hover:bg-blush/30 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                Previous
                            </button>
                            <div id="pageNumbers" class="flex space-x-1">
                                <!-- Page numbers will be inserted here -->
                            </div>
                            <button id="nextPage" class="px-3 py-1 border border-blush rounded text-espressoLighter hover:bg-blush/30 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                Next
                            </button>
                        </div>
                    </div>
                </div>

            </div>

        </main>

        <!-- Add Class Modal -->
        <div id="addClassModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0"></div>
            <div class="fixed inset-0 flex items-center justify-center p-4">
                <div class="bg-whitePure rounded-xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden flex flex-col">
                    <!-- Modal Header -->
                    <div class="px-6 py-4 border-b border-blush bg-petal/30">
                        <h3 class="text-lg font-semibold text-espresso">Add New Class</h3>
                    </div>

                    <!-- Modal Body -->
                    <div class="flex-1 overflow-y-auto p-6">
                        <form id="addClassForm" class="space-y-4">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <!-- Class Name -->
                                <div>
                                    <label for="addClassName" class="block text-sm font-medium mb-1 text-espresso">Class Name *</label>
                                    <input type="text" id="addClassName" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Class Type -->
                                <div>
                                    <label for="addClassType" class="block text-sm font-medium mb-1 text-espresso">Class Type *</label>
                                    <select id="addClassType" required 
                                            class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                        <option value="">Select Type</option>
                                        <option value="mat pilates">Mat Pilates</option>
                                        <option value="reformer">Reformer</option>
                                    </select>
                                </div>

                                <!-- Class Level -->
                                <div>
                                    <label for="addClassLevel" class="block text-sm font-medium mb-1 text-espresso">Class Level *</label>
                                    <select id="addClassLevel" required 
                                            class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                        <option value="">Select Level</option>
                                        <option value="beginner">Beginner</option>
                                        <option value="intermediate">Intermediate</option>
                                        <option value="advanced">Advanced</option>
                                    </select>
                                </div>

                                <!-- Class Status -->
                                <div>
                                    <label for="addClassStatus" class="block text-sm font-medium mb-1 text-espresso">Class Status *</label>
                                    <select id="addClassStatus" required 
                                            class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                        <option value="active" selected>Active (Visible to instructors)</option>
                                        <option value="inactive">Inactive (Hidden from instructors)</option>
                                    </select>
                                </div>

                                <!-- Class Date -->
                                <div>
                                    <label for="addClassDate" class="block text-sm font-medium mb-1 text-espresso">Class Date *</label>
                                    <input type="date" id="addClassDate" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Number of Participants -->
                                <div>
                                    <label for="addNoOfParticipant" class="block text-sm font-medium mb-1 text-espresso">No. of Participants *</label>
                                    <input type="number" id="addNoOfParticipant" min="1" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Start Time -->
                                <div>
                                    <label for="addClassStartTime" class="block text-sm font-medium mb-1 text-espresso">Start Time *</label>
                                    <input type="time" id="addClassStartTime" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- End Time -->
                                <div>
                                    <label for="addClassEndTime" class="block text-sm font-medium mb-1 text-espresso">End Time *</label>
                                    <input type="time" id="addClassEndTime" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Location (Full Width) -->
                                <div class="md:col-span-2">
                                    <label for="addLocation" class="block text-sm font-medium mb-1 text-espresso">Location *</label>
                                    <input type="text" id="addLocation" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>
                            </div>

                            <!-- Description -->
                            <div>
                                <label for="addDescription" class="block text-sm font-medium mb-1 text-espresso">Description *</label>
                                <textarea id="addDescription" rows="3" required 
                                          class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty"></textarea>
                            </div>
                        </form>
                    </div>

                    <!-- Modal Footer -->
                    <div class="px-6 py-4 border-t border-blush bg-cloud">
                        <div class="flex justify-end space-x-3">
                            <button type="button" id="cancelAddBtn" 
                                    class="btn-secondary px-5 py-2 rounded-lg font-medium shadow-sm">
                                Cancel
                            </button>
                            <button type="submit" form="addClassForm" 
                                    class="btn-primary px-5 py-2 rounded-lg font-medium shadow-sm">
                                Submit Class & Generate QR
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Edit Class Modal -->
        <div id="editClassModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0"></div>
            <div class="fixed inset-0 flex items-center justify-center p-4">
                <div class="bg-whitePure rounded-xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden flex flex-col">
                    <!-- Modal Header -->
                    <div class="px-6 py-4 border-b border-blush bg-petal/30">
                        <h3 class="text-lg font-semibold text-espresso">Edit Class Details</h3>
                        <p class="text-sm text-espressoLighter mt-1">
                            Edit basic class information. Use "Emergency Withdraw" to remove instructors.
                        </p>
                    </div>

                    <!-- Modal Body -->
                    <div class="flex-1 overflow-y-auto p-6">
                        <form id="editClassForm" class="space-y-4">
                            <input type="hidden" id="editClassId">

                            <!-- Time Remaining Warning -->
                            <div id="editTimeWarning" class="hidden p-4 rounded-lg mb-4">
                                <div id="editWarningContent"></div>
                            </div>

                            <!-- Instructor Warning -->
                            <div id="editInstructorWarning" class="hidden p-4 border border-warningText/30 bg-warningBg/20 rounded-lg mb-4">
                                <div class="flex items-start">
                                    <svg class="w-5 h-5 mr-2 text-warningText mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.998-.833-2.732 0L4.196 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                                    </svg>
                                    <div>
                                        <p class="text-warningText font-medium" id="editInstructorWarningTitle"></p>
                                        <p class="text-sm text-espresso mt-1" id="editInstructorWarningText"></p>
                                    </div>
                                </div>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <!-- Class Name -->
                                <div>
                                    <label for="editClassName" class="block text-sm font-medium mb-1 text-espresso">Class Name *</label>
                                    <input type="text" id="editClassName" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Class Type -->
                                <div>
                                    <label for="editClassType" class="block text-sm font-medium mb-1 text-espresso">Class Type *</label>
                                    <select id="editClassType" required 
                                            class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                        <option value="">Select Type</option>
                                        <option value="mat pilates">Mat Pilates</option>
                                        <option value="reformer">Reformer</option>
                                    </select>
                                </div>

                                <!-- Class Level -->
                                <div>
                                    <label for="editClassLevel" class="block text-sm font-medium mb-1 text-espresso">Class Level *</label>
                                    <select id="editClassLevel" required 
                                            class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                        <option value="">Select Level</option>
                                        <option value="beginner">Beginner</option>
                                        <option value="intermediate">Intermediate</option>
                                        <option value="advanced">Advanced</option>
                                    </select>
                                </div>

                                <!-- Class Status -->
                                <div>
                                    <label for="editClassStatus" class="block text-sm font-medium mb-1 text-espresso">Class Status *</label>
                                    <select id="editClassStatus" required 
                                            class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                        <option value="active">Active (Visible to instructors)</option>
                                        <option value="inactive">Inactive (Hidden from instructors)</option>
                                    </select>
                                </div>

                                <!-- Class Date -->
                                <div>
                                    <label for="editClassDate" class="block text-sm font-medium mb-1 text-espresso">Class Date *</label>
                                    <input type="date" id="editClassDate" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Number of Participants -->
                                <div>
                                    <label for="editNoOfParticipant" class="block text-sm font-medium mb-1 text-espresso">No. of Participants *</label>
                                    <input type="number" id="editNoOfParticipant" min="1" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Start Time -->
                                <div>
                                    <label for="editClassStartTime" class="block text-sm font-medium mb-1 text-espresso">Start Time *</label>
                                    <input type="time" id="editClassStartTime" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- End Time -->
                                <div>
                                    <label for="editClassEndTime" class="block text-sm font-medium mb-1 text-espresso">End Time *</label>
                                    <input type="time" id="editClassEndTime" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Location (Full Width) -->
                                <div class="md:col-span-2">
                                    <label for="editLocation" class="block text-sm font-medium mb-1 text-espresso">Location *</label>
                                    <input type="text" id="editLocation" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>
                            </div>

                            <!-- Description -->
                            <div>
                                <label for="editDescription" class="block text-sm font-medium mb-1 text-espresso">Description *</label>
                                <textarea id="editDescription" rows="3" required 
                                          class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty"></textarea>
                            </div>

                            <!-- Generate New QR Code -->
                            <div class="border-t border-blush/50 pt-4">
                                <div class="flex items-center space-x-2">
                                    <input type="checkbox" id="generateNewQR" class="w-4 h-4 text-dusty focus:ring-dusty/50 border-blush rounded">
                                    <label for="generateNewQR" class="text-sm text-espresso">
                                        Generate new QR code for this class
                                    </label>
                                </div>
                                <p class="text-xs text-espressoLighter mt-1 ml-6">
                                    If checked, a new QR code will be generated when saving changes
                                </p>
                            </div>
                        </form>
                    </div>

                    <!-- Modal Footer -->
                    <div class="px-6 py-4 border-t border-blush bg-cloud">
                        <div class="flex justify-end space-x-3">
                            <button type="button" id="cancelEditBtn" 
                                    class="btn-secondary px-5 py-2 rounded-lg font-medium shadow-sm">
                                Cancel
                            </button>
                            <button type="submit" form="editClassForm" 
                                    class="btn-primary px-5 py-2 rounded-lg font-medium shadow-sm">
                                Save Changes
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Emergency Withdraw Modal -->
        <div id="emergencyWithdrawModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0"></div>
            <div class="fixed inset-0 flex items-center justify-center p-4">
                <div class="bg-whitePure rounded-xl shadow-2xl w-full max-w-md">
                    <div class="p-6">
                        <div class="text-center">
                            <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-warningBg">
                                <svg class="h-6 w-6 text-warningText" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.998-.833-2.732 0L4.196 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                                </svg>
                            </div>
                            <h3 class="mt-4 text-lg font-medium text-espresso">Emergency Withdraw Instructor</h3>
                            <div class="mt-4 text-left">
                                <div id="withdrawInstructorInfo" class="mb-4"></div>
                                <div id="withdrawTimeWarning" class="hidden p-3 bg-warningBg/30 rounded-lg mb-4"></div>
                                <div id="withdrawReliefInfo" class="hidden p-3 bg-infoBg/30 rounded-lg mb-4"></div>
                                <div id="withdrawConsequences" class="p-3 bg-espresso/5 rounded-lg"></div>
                            </div>
                        </div>
                        <div class="mt-6 flex justify-center space-x-3">
                            <button type="button" id="cancelWithdrawBtn" 
                                    class="btn-secondary px-5 py-2 rounded-lg font-medium shadow-sm">
                                Cancel
                            </button>
                            <button type="button" id="confirmWithdrawBtn" 
                                    class="bg-warningBg text-warningText hover:bg-warningBg/90 px-5 py-2 rounded-lg font-medium shadow-sm">
                                Confirm Withdraw
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- QR Code Modal -->
        <div id="qrModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0"></div>
            <div class="fixed inset-0 flex items-center justify-center p-4">
                <div class="bg-whitePure rounded-xl shadow-2xl w-full max-w-md">
                    <div class="p-6">
                        <div class="text-center">
                            <h3 class="text-lg font-semibold mb-4 text-espresso">Class QR Code</h3>
                            <div class="mb-4 flex justify-center">
                                <img id="qrModalImage" src="" alt="QR Code" class="w-64 h-64 border-4 border-blush rounded-lg">
                            </div>
                            <p class="text-sm text-espressoLighter mb-6">
                                Scan this QR code for class information
                            </p>
                            <div class="flex justify-center space-x-3">
                                <button type="button" id="closeQRBtn" 
                                        class="btn-secondary px-5 py-2 rounded-lg font-medium shadow-sm">
                                    Close
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div id="deleteModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0"></div>
            <div class="fixed inset-0 flex items-center justify-center p-4">
                <div class="bg-whitePure rounded-xl shadow-2xl w-full max-w-md">
                    <div class="p-6">
                        <div class="text-center">
                            <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-dangerBg">
                                <svg class="h-6 w-6 text-dangerText" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                                </svg>
                            </div>
                            <h3 class="mt-4 text-lg font-medium text-espresso">Delete Class</h3>
                            <p class="mt-2 text-sm text-espressoLighter">
                                Are you sure you want to delete this class? This action cannot be undone.
                            </p>
                            <div id="deleteInstructorWarning" class="hidden mt-4 p-3 bg-warningBg/30 rounded-lg">
                                <p class="text-sm text-warningText">This class has an instructor assigned. Deleting will remove it from the instructor's schedule.</p>
                            </div>
                        </div>
                        <div class="mt-6 flex justify-center space-x-3">
                            <button type="button" id="cancelDeleteBtn" 
                                    class="btn-secondary px-5 py-2 rounded-lg font-medium shadow-sm">
                                Cancel
                            </button>
                            <button type="button" id="confirmDeleteBtn" 
                                    class="bg-dangerBg text-dangerText hover:bg-dangerBg/90 px-5 py-2 rounded-lg font-medium shadow-sm">
                                Delete Class
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
            var classesData = [];
            var currentPage = 1;
            var itemsPerPage = 10;
            var filteredData = [];

            // DOM elements
            var classesTableBody = document.getElementById('classesTableBody');
            var noClassesMessage = document.getElementById('noClassesMessage');
            var pagination = document.getElementById('pagination');
            var pageNumbers = document.getElementById('pageNumbers');
            var prevPageBtn = document.getElementById('prevPage');
            var nextPageBtn = document.getElementById('nextPage');
            var startRowSpan = document.getElementById('startRow');
            var endRowSpan = document.getElementById('endRow');
            var totalRowsSpan = document.getElementById('totalRows');
            var loadingSpinner = document.getElementById('loadingSpinner');

            // Modal elements
            var addClassModal = document.getElementById('addClassModal');
            var editClassModal = document.getElementById('editClassModal');
            var emergencyWithdrawModal = document.getElementById('emergencyWithdrawModal');
            var qrModal = document.getElementById('qrModal');
            var deleteModal = document.getElementById('deleteModal');
            var addClassBtn = document.getElementById('addClassBtn');
            var cancelAddBtn = document.getElementById('cancelAddBtn');
            var cancelEditBtn = document.getElementById('cancelEditBtn');
            var cancelWithdrawBtn = document.getElementById('cancelWithdrawBtn');
            var closeQRBtn = document.getElementById('closeQRBtn');
            var cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
            var addClassForm = document.getElementById('addClassForm');
            var editClassForm = document.getElementById('editClassForm');
            var qrModalImage = document.getElementById('qrModalImage');
            var editTimeWarning = document.getElementById('editTimeWarning');
            var editWarningContent = document.getElementById('editWarningContent');
            var editInstructorWarning = document.getElementById('editInstructorWarning');
            var editInstructorWarningTitle = document.getElementById('editInstructorWarningTitle');
            var editInstructorWarningText = document.getElementById('editInstructorWarningText');
            var withdrawInstructorInfo = document.getElementById('withdrawInstructorInfo');
            var withdrawTimeWarning = document.getElementById('withdrawTimeWarning');
            var withdrawReliefInfo = document.getElementById('withdrawReliefInfo');
            var withdrawConsequences = document.getElementById('withdrawConsequences');
            var confirmWithdrawBtn = document.getElementById('confirmWithdrawBtn');
            var deleteInstructorWarning = document.getElementById('deleteInstructorWarning');

            // Filter elements
            var filterStatus = document.getElementById('filterStatus');
            var filterDate = document.getElementById('filterDate');
            var filterType = document.getElementById('filterType');
            var filterLevel = document.getElementById('filterLevel');
            var applyFilterBtn = document.getElementById('applyFilterBtn');
            var resetFilterBtn = document.getElementById('resetFilterBtn');

            // Variables
            var classToDelete = null;
            var classToWithdraw = null;
            var currentEditingClass = null;

            // Helper functions
            function calculateHoursRemaining(classItem) {
                var classDateTime = new Date(classItem.classDate + 'T' + classItem.classStartTime);
                var now = new Date();
                var diffMs = classDateTime - now;
                var diffHours = Math.floor(diffMs / (1000 * 60 * 60));
                var diffMinutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));

                return {
                    hours: diffHours,
                    minutes: diffMinutes,
                    totalHours: diffHours + (diffMinutes / 60),
                    isPast: diffMs < 0
                };
            }

            function getTimeRemainingDisplay(classItem) {
                var timeRemaining = calculateHoursRemaining(classItem);

                if (timeRemaining.isPast) {
                    return {
                        text: "Class has passed",
                        badgeClass: "bg-espressoLighter/20 text-espressoLighter",
                        isPast: true
                    };
                }

                if (timeRemaining.hours < 0) {
                    return {
                        text: "Starting now",
                        badgeClass: "bg-criticalTimeBg text-criticalTimeText",
                        isCritical: true
                    };
                }

                var displayText = timeRemaining.hours + "h " + timeRemaining.minutes + "m remaining";

                if (timeRemaining.totalHours < 24) {
                    return {
                        text: displayText,
                        badgeClass: "bg-criticalTimeBg text-criticalTimeText",
                        isCritical: true
                    };
                } else if (timeRemaining.totalHours < 48) {
                    return {
                        text: displayText,
                        badgeClass: "bg-warningTimeBg text-warningTimeText",
                        isWarning: true
                    };
                } else {
                    return {
                        text: displayText,
                        badgeClass: "bg-safeTimeBg text-safeTimeText",
                        isSafe: true
                    };
                }
            }

            function canChangeStatus(classItem, newStatus) {
                var timeRemaining = calculateHoursRemaining(classItem);

                // Cannot change to inactive if less than 24 hours remaining
                if (newStatus === "inactive" && timeRemaining.totalHours < 24 && !timeRemaining.isPast) {
                    return false;
                }

                // Cannot reactivate if less than 24 hours remaining
                if (classItem.classStatus === "inactive" && newStatus === "active" &&
                        timeRemaining.totalHours < 24 && !timeRemaining.isPast) {
                    return false;
                }

                return true;
            }

            function hasInstructor(classItem) {
                return classItem.confirmedInstructor !== "N/A" && classItem.confirmedInstructor !== "";
            }

            // Load classes from server
            function loadClasses() {
                showLoading();

                var params = new URLSearchParams();
                if (filterStatus.value)
                    params.append('status', filterStatus.value);
                if (filterDate.value)
                    params.append('date', filterDate.value);
                if (filterType.value)
                    params.append('type', filterType.value);
                if (filterLevel.value)
                    params.append('level', filterLevel.value);

                fetch('../ClassManagementServlet?action=getClasses&' + params.toString())
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                classesData = data.data;
                                filteredData = classesData.slice();
                                renderTable();
                            } else {
                                alert('Error loading classes: ' + data.message);
                            }
                            hideLoading();
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('Failed to load classes');
                            hideLoading();
                        });
            }

            // Initialize
            function init() {
                // Set today's date as minimum for date inputs
                var today = new Date().toISOString().split('T')[0];
                document.getElementById('addClassDate').min = today;

                // Load initial data
                loadClasses();
                setupEventListeners();
            }

            // Setup event listeners
            function setupEventListeners() {
                // Add class button
                addClassBtn.addEventListener('click', function () {
                    addClassModal.classList.remove('hidden');
                });

                // Cancel buttons
                cancelAddBtn.addEventListener('click', function () {
                    addClassModal.classList.add('hidden');
                });

                cancelEditBtn.addEventListener('click', function () {
                    editClassModal.classList.add('hidden');
                    currentEditingClass = null;
                });

                cancelWithdrawBtn.addEventListener('click', function () {
                    emergencyWithdrawModal.classList.add('hidden');
                    classToWithdraw = null;
                });

                closeQRBtn.addEventListener('click', function () {
                    qrModal.classList.add('hidden');
                });

                // Form submissions
                addClassForm.addEventListener('submit', function (e) {
                    e.preventDefault();
                    saveNewClass();
                });

                editClassForm.addEventListener('submit', function (e) {
                    e.preventDefault();
                    updateClass();
                });

                // Filter buttons
                applyFilterBtn.addEventListener('click', function () {
                    loadClasses();
                });

                resetFilterBtn.addEventListener('click', function () {
                    filterStatus.value = '';
                    filterDate.value = '';
                    filterType.value = '';
                    filterLevel.value = '';
                    loadClasses();
                });

                // Pagination buttons
                prevPageBtn.addEventListener('click', function () {
                    if (currentPage > 1) {
                        currentPage--;
                        renderTable();
                    }
                });

                nextPageBtn.addEventListener('click', function () {
                    var totalPages = Math.ceil(filteredData.length / itemsPerPage);
                    if (currentPage < totalPages) {
                        currentPage++;
                        renderTable();
                    }
                });

                // Delete buttons
                cancelDeleteBtn.addEventListener('click', function () {
                    deleteModal.classList.add('hidden');
                });

                document.getElementById('confirmDeleteBtn').addEventListener('click', function () {
                    if (classToDelete) {
                        deleteClass(classToDelete);
                        deleteModal.classList.add('hidden');
                        classToDelete = null;
                    }
                });

                // Emergency withdraw button
                confirmWithdrawBtn.addEventListener('click', function () {
                    if (classToWithdraw) {
                        emergencyWithdraw(classToWithdraw);
                    }
                });

                // Listen to status change in edit modal
                document.getElementById('editClassStatus').addEventListener('change', function () {
                    updateEditModalWarnings();
                });
            }

            // Show loading spinner
            function showLoading() {
                loadingSpinner.classList.remove('hidden');
                classesTableBody.parentElement.classList.add('hidden');
                pagination.classList.add('hidden');
                noClassesMessage.classList.add('hidden');
            }

            // Hide loading spinner
            function hideLoading() {
                loadingSpinner.classList.add('hidden');
            }

            // Render classes table
            function renderTable() {
                var startIndex = (currentPage - 1) * itemsPerPage;
                var endIndex = Math.min(startIndex + itemsPerPage, filteredData.length);
                var pageData = filteredData.slice(startIndex, endIndex);

                // Clear table
                classesTableBody.innerHTML = '';

                if (pageData.length === 0) {
                    noClassesMessage.classList.remove('hidden');
                    classesTableBody.parentElement.classList.add('hidden');
                    pagination.classList.add('hidden');
                    return;
                }

                noClassesMessage.classList.add('hidden');
                classesTableBody.parentElement.classList.remove('hidden');
                pagination.classList.remove('hidden');

                // Add rows
                for (var i = 0; i < pageData.length; i++) {
                    var classItem = pageData[i];
                    var row = document.createElement('tr');

                    // Format date and time
                    var formattedDate = new Date(classItem.classDate + 'T' + classItem.classStartTime).toLocaleDateString('en-US', {
                        weekday: 'short',
                        month: 'short',
                        day: 'numeric',
                        year: 'numeric'
                    });
                    var timeRange = classItem.classStartTime + ' - ' + classItem.classEndTime;

                    // Get time remaining info
                    var timeRemainingInfo = getTimeRemainingDisplay(classItem);

                    // Status badge
                    var statusBadge = '';
                    if (classItem.classStatus === 'active' && !classItem.isAutoInactive) {
                        statusBadge = '<span class="px-2 py-1 text-xs rounded-full bg-activeBg text-activeText font-medium">Active</span>';
                    } else if (classItem.isAutoInactive) {
                        statusBadge = '<span class="px-2 py-1 text-xs rounded-full bg-autoInactiveBg text-autoInactiveText font-medium">⚠️ Auto-Inactive</span>';
                    } else {
                        statusBadge = '<span class="px-2 py-1 text-xs rounded-full bg-inactiveBg text-inactiveText font-medium">Inactive</span>';
                    }

                    // Instructor info
                    var instructorInfo = '<div class="space-y-1">';
                    if (classItem.confirmedInstructor === "N/A") {
                        instructorInfo += '<div class="text-sm text-espressoLighter italic">No instructor assigned</div>';
                    } else {
                        instructorInfo += '<div class="flex items-center space-x-2">' +
                                '<span class="px-2 py-1 text-xs rounded-full bg-confirmedBg text-confirmedText font-medium">Confirmed: ' + classItem.confirmedInstructor + '</span>' +
                                '</div>';
                        if (classItem.pendingInstructor) {
                            instructorInfo += '<div class="mt-1">' +
                                    '<span class="px-2 py-1 text-xs rounded-full bg-pendingReliefBg text-pendingReliefText font-medium">Pending Relief: ' + classItem.pendingInstructor + '</span>' +
                                    '</div>';
                        }
                    }
                    instructorInfo += '</div>';

                    // Type and level chips
                    var typeChipColor = classItem.classType === 'mat pilates' ? 'bg-chipSand' : 'bg-chipTeal';
                    var levelChipColor = '';
                    if (classItem.classLevel === 'beginner') {
                        levelChipColor = 'bg-successBg text-successText';
                    } else if (classItem.classLevel === 'intermediate') {
                        levelChipColor = 'bg-warningBg text-warningText';
                    } else {
                        levelChipColor = 'bg-dangerBg text-dangerText';
                    }

                    // Action buttons
                    var actionButtons = '';
                    if (hasInstructor(classItem)) {
                        // Has instructor - Edit + Emergency Withdraw
                        actionButtons = '<div class="flex flex-col space-y-2">' +
                                '<button onclick="editClass(' + classItem.classID + ')" class="text-teal hover:text-tealHover font-medium text-left">Edit Class</button>' +
                                '<button onclick="showEmergencyWithdraw(' + classItem.classID + ')" class="text-warningText hover:text-warningText/80 font-medium text-left">Emergency Withdraw</button>' +
                                '</div>';
                    } else {
                        // No instructor - Edit + Delete
                        actionButtons = '<div class="flex items-center space-x-2">' +
                                '<button onclick="editClass(' + classItem.classID + ')" class="text-teal hover:text-tealHover font-medium">Edit</button>' +
                                '<span class="text-blush">|</span>' +
                                '<button onclick="confirmDelete(' + classItem.classID + ')" class="text-dangerText hover:text-dangerText/80 font-medium">Delete</button>' +
                                '</div>';
                    }

                    row.innerHTML =
                            '<td class="px-6 py-4">' +
                            '<div class="text-sm font-semibold text-espresso">' + classItem.className + '</div>' +
                            '<div class="text-sm text-espressoLighter mt-1">' + classItem.location + '</div>' +
                            '</td>' +
                            '<td class="px-6 py-4">' +
                            '<div class="text-sm font-medium text-espresso">' + formattedDate + '</div>' +
                            '<div class="text-sm text-espressoLighter">' + timeRange + '</div>' +
                            '</td>' +
                            '<td class="px-6 py-4">' +
                            '<span class="inline-block px-2 py-1 text-xs rounded-full font-medium ' + timeRemainingInfo.badgeClass + '">' + timeRemainingInfo.text + '</span>' +
                            '</td>' +
                            '<td class="px-6 py-4">' +
                            '<div class="space-y-1">' +
                            '<span class="inline-block px-2 py-1 text-xs rounded-full ' + typeChipColor + '">' + classItem.classType + '</span>' +
                            '<span class="inline-block px-2 py-1 text-xs rounded-full ' + levelChipColor + ' ml-1">' + classItem.classLevel + '</span>' +
                            '</div>' +
                            '<div class="text-sm text-espressoLighter mt-1">' + classItem.noOfParticipant + ' participants</div>' +
                            '</td>' +
                            '<td class="px-6 py-4">' +
                            instructorInfo +
                            '</td>' +
                            '<td class="px-6 py-4">' +
                            statusBadge +
                            '</td>' +
                            '<td class="px-6 py-4">' +
                            '<button onclick="viewQRCode(' + classItem.classID + ')" class="inline-block hover:opacity-80 transition-opacity">' +
                            '<img src="../' + classItem.qrcode + '" alt="QR Code" class="w-16 h-16 border-2 border-blush rounded-lg shadow-sm">' +
                            '</button>' +
                            '</td>' +
                            '<td class="px-6 py-4 text-sm font-medium">' +
                            actionButtons +
                            '</td>';

                    classesTableBody.appendChild(row);
                }

                // Update pagination info
                updatePaginationInfo();
            }

            // Update pagination information
            function updatePaginationInfo() {
                var totalItems = filteredData.length;
                var totalPages = Math.ceil(totalItems / itemsPerPage);
                var startIndex = (currentPage - 1) * itemsPerPage + 1;
                var endIndex = Math.min(currentPage * itemsPerPage, totalItems);

                startRowSpan.textContent = startIndex;
                endRowSpan.textContent = endIndex;
                totalRowsSpan.textContent = totalItems;

                // Update button states
                prevPageBtn.disabled = currentPage === 1;
                nextPageBtn.disabled = currentPage === totalPages;

                // Generate page numbers
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
                    pageBtn.className = 'px-3 py-1 rounded text-sm min-w-[40px] transition-colors ' +
                            (i === currentPage ? 'bg-dusty text-whitePure' : 'border border-blush text-espressoLighter hover:bg-blush/30');
                    pageBtn.addEventListener('click', (function (page) {
                        return function () {
                            currentPage = page;
                            renderTable();
                        };
                    })(i));
                    pageNumbers.appendChild(pageBtn);
                }
            }

            // Save new class
            function saveNewClass() {
                var formData = new FormData();
                formData.append('action', 'addClass');
                formData.append('className', document.getElementById('addClassName').value);
                formData.append('classType', document.getElementById('addClassType').value);
                formData.append('classLevel', document.getElementById('addClassLevel').value);
                formData.append('classStatus', document.getElementById('addClassStatus').value);
                formData.append('classDate', document.getElementById('addClassDate').value);
                formData.append('classStartTime', document.getElementById('addClassStartTime').value);
                formData.append('classEndTime', document.getElementById('addClassEndTime').value);
                formData.append('noOfParticipant', document.getElementById('addNoOfParticipant').value);
                formData.append('location', document.getElementById('addLocation').value);
                formData.append('description', document.getElementById('addDescription').value);

                fetch('../ClassManagementServlet', {
                    method: 'POST',
                    body: new URLSearchParams(formData)
                })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                alert('Class added successfully!');
                                addClassModal.classList.add('hidden');
                                addClassForm.reset();
                                loadClasses();
                            } else {
                                alert('Error: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('Failed to add class');
                        });
            }

            // Edit class
            window.editClass = function (classId) {
                fetch('../ClassManagementServlet?action=getClass&classId=' + classId)
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                var classItem = data.data;
                                currentEditingClass = classItem;

                                document.getElementById('editClassId').value = classItem.classID;
                                document.getElementById('editClassName').value = classItem.className;
                                document.getElementById('editClassType').value = classItem.classType;
                                document.getElementById('editClassLevel').value = classItem.classLevel;
                                document.getElementById('editClassStatus').value = classItem.classStatus;
                                document.getElementById('editClassDate').value = classItem.classDate;
                                document.getElementById('editClassStartTime').value = classItem.classStartTime;
                                document.getElementById('editClassEndTime').value = classItem.classEndTime;
                                document.getElementById('editNoOfParticipant').value = classItem.noOfParticipant;
                                document.getElementById('editLocation').value = classItem.location;
                                document.getElementById('editDescription').value = classItem.description;
                                document.getElementById('generateNewQR').checked = false;

                                // Update warnings
                                updateEditModalWarnings();

                                editClassModal.classList.remove('hidden');
                            } else {
                                alert('Error loading class: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('Failed to load class details');
                        });
            };

            // Update edit modal warnings
            function updateEditModalWarnings() {
                if (!currentEditingClass)
                    return;

                var newStatus = document.getElementById('editClassStatus').value;
                var timeRemaining = calculateHoursRemaining(currentEditingClass);
                var canChange = canChangeStatus(currentEditingClass, newStatus);

                editTimeWarning.classList.add('hidden');
                editInstructorWarning.classList.add('hidden');

                // Check if status change is allowed
                if (!canChange) {
                    editTimeWarning.classList.remove('hidden');

                    if (newStatus === "inactive") {
                        editTimeWarning.className = "p-4 rounded-lg mb-4 bg-dangerBg/20 border border-dangerText/30";
                        editWarningContent.innerHTML =
                                '<div class="flex items-start">' +
                                '<svg class="w-5 h-5 mr-2 text-dangerText mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>' +
                                '</svg>' +
                                '<div>' +
                                '<p class="text-dangerText font-medium">Cannot Set to Inactive</p>' +
                                '<p class="text-sm text-espresso mt-1">Less than 24 hours remaining before class start. Status must remain active.</p>' +
                                '</div>' +
                                '</div>';

                        // Force status back to active
                        document.getElementById('editClassStatus').value = "active";
                    } else if (newStatus === "active" && currentEditingClass.classStatus === "inactive") {
                        editTimeWarning.className = "p-4 rounded-lg mb-4 bg-dangerBg/20 border border-dangerText/30";
                        editWarningContent.innerHTML =
                                '<div class="flex items-start">' +
                                '<svg class="w-5 h-5 mr-2 text-dangerText mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>' +
                                '</svg>' +
                                '<div>' +
                                '<p class="text-dangerText font-medium">Cannot Reactivate Class</p>' +
                                '<p class="text-sm text-espresso mt-1">Less than 24 hours remaining before class start. Class must remain inactive.</p>' +
                                '</div>' +
                                '</div>';

                        // Force status back to inactive
                        document.getElementById('editClassStatus').value = "inactive";
                    }
                }

                // Check if trying to inactive a class with instructor (not allowed in Edit)
                if (newStatus === "inactive" && hasInstructor(currentEditingClass)) {
                    editInstructorWarning.classList.remove('hidden');
                    editInstructorWarningTitle.textContent = "Cannot Inactive Class with Instructor";
                    editInstructorWarningText.textContent = "This class has a confirmed instructor. To withdraw instructor and set to inactive, use the 'Emergency Withdraw' button instead.";

                    // Force status back to active
                    document.getElementById('editClassStatus').value = "active";
                }
            }

            // Show emergency withdraw modal
            window.showEmergencyWithdraw = function (classId) {
                var classItem = classesData.find(function (item) {
                    return item.classID === classId;
                });

                if (classItem && hasInstructor(classItem)) {
                    classToWithdraw = classItem;

                    var timeRemaining = calculateHoursRemaining(classItem);

                    // Instructor info
                    withdrawInstructorInfo.innerHTML =
                            '<p class="text-espresso mb-2"><span class="font-medium">Instructor:</span> ' + classItem.confirmedInstructor + '</p>' +
                            '<p class="text-espresso"><span class="font-medium">Class:</span> ' + classItem.className + ' (' +
                            new Date(classItem.classDate).toLocaleDateString() + ' ' + classItem.classStartTime + ')</p>';

                    // Time warning
                    if (timeRemaining.totalHours < 24 && !timeRemaining.isPast) {
                        withdrawTimeWarning.classList.remove('hidden');
                        withdrawTimeWarning.innerHTML =
                                '<div class="flex items-start">' +
                                '<svg class="w-5 h-5 mr-2 text-warningText mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.998-.833-2.732 0L4.196 16.5c-.77.833.192 2.5 1.732 2.5z"></path>' +
                                '</svg>' +
                                '<div>' +
                                '<p class="text-warningText font-medium">Less than 24 hours remaining</p>' +
                                '<p class="text-sm text-espresso mt-1">Emergency withdrawal at this time has specific consequences.</p>' +
                                '</div>' +
                                '</div>';
                    } else {
                        withdrawTimeWarning.classList.add('hidden');
                    }

                    // Relief info
                    if (classItem.pendingInstructor) {
                        withdrawReliefInfo.classList.remove('hidden');
                        withdrawReliefInfo.innerHTML =
                                '<div class="flex items-start">' +
                                '<svg class="w-5 h-5 mr-2 text-infoText mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>' +
                                '</svg>' +
                                '<div>' +
                                '<p class="text-infoText font-medium">Relief Instructor Available</p>' +
                                '<p class="text-sm text-espresso mt-1">' + classItem.pendingInstructor + ' will automatically replace ' + classItem.confirmedInstructor + '</p>' +
                                '</div>' +
                                '</div>';
                    } else {
                        withdrawReliefInfo.classList.add('hidden');
                    }

                    // Consequences
                    var consequencesText = '';
                    if (timeRemaining.totalHours >= 24 || timeRemaining.isPast) {
                        consequencesText = '<p class="text-sm text-espresso">Instructor will be withdrawn from this class. Class status will remain active.</p>';
                    } else if (timeRemaining.totalHours < 24 && classItem.pendingInstructor) {
                        consequencesText = '<p class="text-sm text-espresso">Relief instructor ' + classItem.pendingInstructor + ' will automatically become the confirmed instructor.</p>';
                    } else if (timeRemaining.totalHours < 24 && !classItem.pendingInstructor) {
                        consequencesText = '<p class="text-sm text-espresso">Class will be cancelled and set to inactive. No replacement instructor available.</p>';
                    }

                    withdrawConsequences.innerHTML = consequencesText;

                    emergencyWithdrawModal.classList.remove('hidden');
                }
            };

            // Emergency withdraw function
            function emergencyWithdraw(classItem) {
                if (!confirm('Are you sure you want to proceed with emergency withdrawal?')) {
                    return;
                }

                var formData = new FormData();
                formData.append('action', 'emergencyWithdraw');
                formData.append('classId', classItem.classID);

                fetch('../ClassManagementServlet', {
                    method: 'POST',
                    body: new URLSearchParams(formData)
                })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                alert(data.message);
                                emergencyWithdrawModal.classList.add('hidden');
                                classToWithdraw = null;
                                loadClasses();
                            } else {
                                alert('Error: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('Failed to process emergency withdrawal');
                        });
            }

            // Update class
            function updateClass() {
                var formData = new FormData();
                formData.append('action', 'updateClass');
                formData.append('classId', document.getElementById('editClassId').value);
                formData.append('className', document.getElementById('editClassName').value);
                formData.append('classType', document.getElementById('editClassType').value);
                formData.append('classLevel', document.getElementById('editClassLevel').value);
                formData.append('classStatus', document.getElementById('editClassStatus').value);
                formData.append('classDate', document.getElementById('editClassDate').value);
                formData.append('classStartTime', document.getElementById('editClassStartTime').value);
                formData.append('classEndTime', document.getElementById('editClassEndTime').value);
                formData.append('noOfParticipant', document.getElementById('editNoOfParticipant').value);
                formData.append('location', document.getElementById('editLocation').value);
                formData.append('description', document.getElementById('editDescription').value);
                formData.append('generateNewQR', document.getElementById('generateNewQR').checked);

                fetch('../ClassManagementServlet', {
                    method: 'POST',
                    body: new URLSearchParams(formData)
                })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                alert(data.message);
                                editClassModal.classList.add('hidden');
                                currentEditingClass = null;
                                loadClasses();
                            } else {
                                alert('Error: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('Failed to update class');
                        });
            }

            // Confirm delete
            window.confirmDelete = function (classId) {
                var classItem = classesData.find(function (item) {
                    return item.classID === classId;
                });

                if (classItem) {
                    if (hasInstructor(classItem)) {
                        alert("Cannot delete class: Class has a confirmed instructor. Use 'Emergency Withdraw' first to remove instructor.");
                        return;
                    }

                    classToDelete = classId;
                    deleteModal.classList.remove('hidden');

                    // Show warning if class has instructor
                    if (hasInstructor(classItem)) {
                        deleteInstructorWarning.classList.remove('hidden');
                    } else {
                        deleteInstructorWarning.classList.add('hidden');
                    }
                }
            };

            // Delete class
            function deleteClass(classId) {
                var formData = new FormData();
                formData.append('action', 'deleteClass');
                formData.append('classId', classId);

                fetch('../ClassManagementServlet', {
                    method: 'POST',
                    body: new URLSearchParams(formData)
                })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                alert(data.message);
                                deleteModal.classList.add('hidden');
                                classToDelete = null;
                                loadClasses();
                            } else {
                                alert('Error: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('Failed to delete class');
                        });
            }

            // View QR code in modal
            window.viewQRCode = function (classId) {
                var classItem = classesData.find(function (item) {
                    return item.classID === classId;
                });

                if (classItem) {
                    qrModalImage.src = '../' + classItem.qrcode;
                    qrModal.classList.remove('hidden');
                }
            };

            // Initialize when DOM is loaded
            document.addEventListener('DOMContentLoaded', init);
        </script>

    </body>
</html>