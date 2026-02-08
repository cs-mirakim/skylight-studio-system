<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Template Page</title>

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
                            // Optional: Roboto Condensed untuk narrow spaces
                            condensed: ['Roboto Condensed', 'ui-sans-serif'],
                            // Optional: Roboto Mono untuk code/data display
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
                
                
                -- change here  --
                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <h2 class="text-xl font-semibold mb-1 text-espresso">
                        Template Page (Flexible View)
                    </h2>
                    <p class="text-sm text-espresso/60">
                        Container ini bersifat <b>dynamic</b>. Kalau content sikit, dia tetap nampak penuh. 
                        Kalau content banyak (seperti di bawah), dia akan memanjang dan menolak footer ke bawah.
                    </p>
                </div>

                <div class="mt-auto pt-10 text-center text-xs text-espresso/30 italic">
                    -- Contents --
                </div>

            </div>

        </main>

        <jsp:include page="../util/footer.jsp" />

        <jsp:include page="../util/sidebar.jsp" />

        <script src="../util/sidebar.js"></script>

    </body>
</html>
