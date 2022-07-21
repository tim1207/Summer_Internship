using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace BookSystem.Models
{
    public class CodeService
    {
        /// <summary>
        /// 資料庫連線
        /// </summary>
        /// <returns></returns>
        private string GetDBConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString.ToString();
        }

        /// <summary>
        /// 取得圖書類別
        /// </summary>
        /// <returns></returns>
        public List<SelectListItem> GetSelectList(string type , bool AllName = false)
        {
            string sql;
            DataTable dt = new DataTable();
            if(type== "ClassName")
            {
                sql = @" SELECT BCL.BOOK_CLASS_NAME AS Name, 
                                   BCL.BOOK_CLASS_ID AS ID
                            FROM BOOK_CLASS AS BCL";
            }
            else if(type== "Status")
            {
                sql = @" SELECT BC.CODE_ID AS ID,
                                   BC.CODE_NAME AS Name
                            FROM BOOK_CODE AS BC
                            WHERE BC.CODE_TYPE='BOOK_STATUS'";
            }
            else
            {
                sql = @"SELECT 
                            mm.[USER_ID] AS KeeperId,
                            mm.USER_CNAME AS KeeperCName,mm.USER_ENAME AS KeeperEName 
                           FROM MEMBER_M mm";
            }
            
            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                SqlDataAdapter sqlAdapter = new SqlDataAdapter(cmd);
                sqlAdapter.Fill(dt);
                conn.Close();
            }
            if (type == "Keeper")
            {
                return (AllName ? this.MapList(dt, "KeeperEName", "KeeperCName", "KeeperId") : this.MapList(dt, "KeeperId", "KeeperEName"));
            }
            return this.MapList(dt);
        }




        /// <summary>
        /// Map List
        /// </summary>
        /// <param name="dt"></param>
        /// <param KeeperEName or KeeperId="str1"></param>
        /// <param KeeperCName or KeeperEName="str2"></param>
        /// <param KeeperId="str3"></param>
        /// <returns></returns>
        private List<SelectListItem> MapList(DataTable dt, string str1="", string str2="", string str3 = "")
        {
            List<SelectListItem> result = new List<SelectListItem>
            {
                new SelectListItem()
                {
                    Text = "請選擇",
                    Value = ""
                }
            };
            if(str1=="" & str2 =="" && str3 == "")
            {
                foreach (DataRow row in dt.Rows)
                {
                    result.Add(new SelectListItem()
                    {
                        Text = row["Name"].ToString(),
                        Value = row["ID"].ToString()
                    });
                }
                return result;
            }
            if (str3 == "")
            {
                foreach (DataRow row in dt.Rows)
                {
                    result.Add(new SelectListItem()
                    {
                        Text = row[str2].ToString(),
                        Value = row[str1].ToString()
                    });
                }
                return result;
            }
            else
            {
                foreach (DataRow row in dt.Rows)
                {
                    result.Add(new SelectListItem()
                    {
                        Text = row[str1].ToString() + '-' + row[str2].ToString(),
                        Value = row[str3].ToString()
                    });
                }
            }
            return result;

        }

        




    }
}