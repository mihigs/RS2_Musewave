using System.Text.Json.Serialization;

namespace Models.DTOs
{
    public class JamendoApiDto
    {
        public class JamendoApiResponse
        {
            [JsonPropertyName("headers")]
            public JamendoHeader Headers { get; set; }
            [JsonPropertyName("results")]
            public List<JamendoResult> Results { get; set; }
        }


        public class JamendoHeader
        {
            [JsonPropertyName("status")]
            public string Status { get; set; }

            [JsonPropertyName("code")]
            public int Code { get; set; }

            [JsonPropertyName("error_message")]
            public string ErrorMessage { get; set; }

            [JsonPropertyName("warnings")]
            public string Warnings { get; set; }

            [JsonPropertyName("results_count")]
            public int ResultsCount { get; set; }

            [JsonPropertyName("next")]
            public string Next { get; set; }
        }


        public class JamendoResult
        {
            [JsonPropertyName("id")]
            public string Id { get; set; }

            [JsonPropertyName("name")]
            public string Name { get; set; }

            [JsonPropertyName("duration")]
            public int Duration { get; set; }

            [JsonPropertyName("artist_id")]
            public string ArtistId { get; set; }

            [JsonPropertyName("artist_name")]
            public string ArtistName { get; set; }

            [JsonPropertyName("artist_idstr")]
            public string ArtistIdstr { get; set; }

            [JsonPropertyName("album_name")]
            public string AlbumName { get; set; }

            [JsonPropertyName("album_id")]
            public string AlbumId { get; set; }

            [JsonPropertyName("license_ccurl")]
            public string LicenseCcurl { get; set; }

            [JsonPropertyName("position")]
            public int Position { get; set; }

            [JsonPropertyName("releasedate")]
            public string ReleaseDate { get; set; }

            [JsonPropertyName("album_image")]
            public string AlbumImage { get; set; }

            [JsonPropertyName("audio")]
            public string Audio { get; set; }

            [JsonPropertyName("audiodownload")]
            public string Audiodownload { get; set; }

            [JsonPropertyName("prourl")]
            public string Prourl { get; set; }

            [JsonPropertyName("shorturl")]
            public string Shorturl { get; set; }

            [JsonPropertyName("shareurl")]
            public string Shareurl { get; set; }

            [JsonPropertyName("waveform")]
            public string Waveform { get; set; }

            [JsonPropertyName("image")]
            public string Image { get; set; }

            [JsonPropertyName("audiodownload_allowed")]
            public bool AudiodownloadAllowed { get; set; }
        }
    }
}
