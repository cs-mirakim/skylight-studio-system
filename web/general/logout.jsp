<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Invalidate the session
    if (session != null) {
        session.invalidate();
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Logged Out - Skylight Studio</title>

        <!-- Font Roboto -->
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
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">

            <div class="w-full bg-whitePure py-6 px-6 md:px-8
                 rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1000px">

                <!-- Logout Content -->
                <div class="flex-1 flex flex-col items-center justify-center py-8">
                    
                    <!-- Icon Section -->
                    <div class="w-32 h-32 rounded-full bg-blush flex items-center justify-center mb-6">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 text-dusty" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                        </svg>
                    </div>
                    
                    <!-- Message -->
                    <h3 class="text-lg font-medium text-espresso mb-4">Thank you for using our system</h3>
                    
                    <!-- Security Message -->
                    <div class="max-w-md mb-8 p-4 rounded-lg border border-petal bg-cloud/50">
                        <div class="flex items-start gap-3">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-dusty flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                            </svg>
                            <div class="text-left">
                                <p class="text-sm text-espresso/70">
                                    Your session has been securely terminated. All login credentials have been cleared from this device.
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="flex flex-col sm:flex-row gap-4 justify-center mb-8">
                        <a href="login.jsp" 
                           class="px-6 py-3 bg-dusty hover:bg-dustyHover text-whitePure rounded-lg font-medium transition-colors flex items-center justify-center gap-2">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
                            </svg>
                            Logout
                        </a>
                        
                        <a href="admin/dashboard_admin.jsp" 
                           class="px-6 py-3 bg-cloud hover:bg-blush text-espresso rounded-lg font-medium transition-colors border border-blush flex items-center justify-center gap-2">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17V7m0 10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2a2 2 0 012 2m0 10a2 2 0 002 2h2a2 2 0 002-2M9 7a2 2 0 012-2h2a2 2 0 012 2m0 10V7m0 10a2 2 0 002 2h2a2 2 0 002-2V7a2 2 0 00-2-2h-2a2 2 0 00-2 2" />
                            </svg>
                            Go to Dashboard
                        </a>
                    </div>

                    

                </div>

           
            </div>

        </main>

        <jsp:include page="../util/footer.jsp" />

        <jsp:include page="../util/sidebar.jsp" />

        <script src="../util/sidebar.js"></script>

        <script>
            // Optional: Clear any remaining session data
            function clearSessionData() {
                // Clear any localStorage items if needed
                localStorage.removeItem('sessionToken');
                localStorage.removeItem('userData');
                
                // Clear any sessionStorage items
                sessionStorage.clear();
            }
            
            // Run on page load
            clearSessionData();
        </script>

    </body>
</html>