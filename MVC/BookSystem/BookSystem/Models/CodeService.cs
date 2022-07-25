using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Mvc;

namespace BookSystem.Models
{
    // 集中處理
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
        public List<SelectListItem> GetBookClassName()
        {
            DataTable dt = new DataTable();
            string sql = @" SELECT BCL.BOOK_CLASS_NAME AS BookStatus, 
                                   BCL.BOOK_CLASS_ID AS CodeID
                            FROM BOOK_CLASS AS BCL";
            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                SqlDataAdapter sqlAdapter = new SqlDataAdapter(cmd);
                sqlAdapter.Fill(dt);
                conn.Close();
            }
            return this.MapBookStatus(dt);
        }

        /// <summary>
        /// 取得借閱狀態
        /// </summary>
        /// <returns></returns>
        public List<SelectListItem> GetBookStatus()
        {
            DataTable dt = new DataTable();
            string sql = @" SELECT BC.CODE_ID AS CodeID,
                                   BC.CODE_NAME AS BookStatus
                            FROM BOOK_CODE AS BC
                            WHERE BC.CODE_TYPE='BOOK_STATUS'";
            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                SqlDataAdapter sqlAdapter = new SqlDataAdapter(cmd);
                sqlAdapter.Fill(dt);
                conn.Close();
            }
            return this.MapBookStatus(dt);
        }


        /// <summary>
        /// Maping 代碼資料
        /// </summary>
        /// <param name="dt"></param>
        /// <returns></returns>
        private List<SelectListItem> MapBookStatus(DataTable dt)
        {
            List<SelectListItem> result = new List<SelectListItem>();
            foreach (DataRow row in dt.Rows)
            {
                result.Add(new SelectListItem()
                {
                    Text = row["BookStatus"].ToString(),
                    Value = row["CodeID"].ToString()
                });
            }
            return result;
        }


        /// <summary>
        /// 取得使用者名字
        /// </summary>
        /// <param name="AllName"></param>
        /// <returns></returns>
        public List<SelectListItem> GetBookKeeper(bool AllName = false)
        {
            DataTable dt = new DataTable();
            string sql = @"SELECT 
                            mm.[USER_ID] AS KeeperId,
                            mm.USER_CNAME AS KeeperCName,mm.USER_ENAME AS KeeperEName 
                           FROM MEMBER_M mm";
            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                SqlDataAdapter sqlAdapter = new SqlDataAdapter(cmd);
                sqlAdapter.Fill(dt);
                conn.Close();
            }
            if (AllName)
            {
                return this.DataToList (dt, "KeeperEName", "KeeperCName", "KeeperId");
            }
            else
            {
                return this.DataToList(dt, "KeeperId", "KeeperEName");
            }
        }


        /// <summary>
        /// 將DataTable資料轉換為SelectList
        /// </summary>
        /// <param name="dt">資料表</param>
        /// <param name="str1"></param>
        /// <param name="str2"></param>
        /// <param name="str3"></param>
        /// <returns></returns>
        private List<SelectListItem> DataToList(DataTable dt, string str1, string str2, string str3 = "")
            // commend
        {
            List<SelectListItem> result = new List<SelectListItem>();
            result.Add(new SelectListItem()
            {
                Text = "請選擇",
                Value = ""
            });

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
            }
            else
            {
                foreach (DataRow row in dt.Rows)
                {
                    result.Add(new SelectListItem()
                    {
                        Text = row[str1].ToString() + '-' + row[str2].ToString(),
                        // 三元運算
                        Value = row[str3].ToString()
                    });
                }
            }

            return result;
        }


    }
}