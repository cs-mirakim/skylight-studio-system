<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%
    // Check if user is logged in
    if (!SessionUtil.isLoggedIn(session)) {
        // Redirect to login page if not logged in
        response.sendRedirect("../general/login.jsp?error=access_denied&message=Please_login_to_access_this_page");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Privacy Policy</title>

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
                 style="max-width:1500px">

                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <h2 class="text-xl font-semibold mb-1 text-espresso">
                        Privacy Policy
                    </h2>
                    <p class="text-sm text-espresso/60">
                        Skylight Studio Management System is committed to protecting your privacy and personal information.
                        Please read this policy carefully to understand how we handle your data.
                    </p>
                </div>

                <div class="space-y-6">
                    <div class="p-4 rounded-lg border border-petal bg-cloud/30">
                        <h3 class="font-bold text-dusty mb-2">1. Your Privacy Matters</h3>
                        <p class="text-sm text-espresso/80 leading-relaxed">
                            This page outlines our commitment to protecting your privacy and the confidentiality of any information submitted through the
                            Skylight Studio Management System. By choosing to register or perform transactions through this platform, you acknowledge that
                            some information may be shared with authorized entities or relevant government agencies, where necessary and permitted by law.
                        </p>
                    </div>

                    <div class="p-4 rounded-lg border border-petal bg-cloud/30">
                        <h3 class="font-bold text-dusty mb-2">2. Log Information</h3>
                        <p class="text-sm text-espresso/80 leading-relaxed">
                            When you access the Skylight Studio Management System, our web server automatically records standard information sent by your
                            browser. This includes your web requests, Internet Protocol (IP) address, browser type and language, as well as the date and time of
                            your visit. These logs help us monitor system performance and improve user experience.
                        </p>
                    </div>

                    <div class="p-4 rounded-lg border border-petal bg-cloud/30">
                        <h3 class="font-bold text-dusty mb-2">3. Data Protection</h3>
                        <p class="text-sm text-espresso/80 leading-relaxed">
                            We are committed to safeguarding your personal data. Industry-standard security technologies, including encryption software, are
                            used to protect the information you provide. Our system follows strict security protocols to prevent unauthorized access or
                            misuse of data.
                        </p>
                    </div>

                    <div class="p-4 rounded-lg border border-petal bg-cloud/30">
                        <h3 class="font-bold text-dusty mb-2">4. Information Collected</h3>
                        <p class="text-sm text-espresso/80 leading-relaxed">
                            No personally identifiable information is collected while you are browsing the Skylight Studio Management System unless you voluntarily
                            provide it (e.g., through registration forms or emails). Any data submitted will only be used for purposes directly related
                            to the system's services.
                        </p>
                    </div>

                    <div class="p-4 rounded-lg border border-petal bg-cloud/30">
                        <h3 class="font-bold text-dusty mb-2">5. Changes to This Policy</h3>
                        <p class="text-sm text-espresso/80 leading-relaxed">
                            Any changes to this privacy policy will be posted on this page. We encourage you to review this section regularly to stay informed
                            about what data is collected, how it is used, and under what circumstances it may be shared.
                        </p>
                    </div>
                </div>

                <div class="mt-auto pt-10 text-center text-xs text-espresso/30 italic">
                    For questions regarding this privacy policy, please contact the system administrator.
                </div>

            </div>

        </main>

        <jsp:include page="../util/footer.jsp" />

        <jsp:include page="../util/sidebar.jsp" />

        <script src="../util/sidebar.js"></script>

    </body>
</html>