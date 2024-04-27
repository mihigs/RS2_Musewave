package com.example.frontend

import android.app.Application
import javax.net.ssl.*
import java.security.cert.X509Certificate

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        disableSSLCertificateChecking()
    }

    private fun disableSSLCertificateChecking() {
        val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
                override fun getAcceptedIssuers(): Array<X509Certificate>? = null
                override fun checkClientTrusted(chain: Array<out X509Certificate>?, authType: String?) {}
                override fun checkServerTrusted(chain: Array<out X509Certificate>?, authType: String?) {}
            })

        try {
            val sc = SSLContext.getInstance("TLS")
            sc.init(null, trustAllCerts, java.security.SecureRandom())
            HttpsURLConnection.setDefaultSSLSocketFactory(sc.socketFactory)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
