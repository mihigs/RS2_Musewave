using System.Reflection;

namespace Models.Constants

{
    public static class Role
    {
        public const string USER = "User";
        public const string ARTIST = "Artist";
        public const string ADMIN = "Admin";

        public static string[] GetAllRoles()
        {
            Type type = typeof(Role);
            FieldInfo[] fields = type.GetFields(BindingFlags.Public | BindingFlags.Static);

            string[] roles = new string[fields.Length];
            for (int i = 0; i < fields.Length; i++)
            {
                if (fields[i].FieldType == typeof(string))
                {
                    roles[i] = (string)fields[i].GetValue(null);
                }
            }

            return roles;
        }
    }
}
