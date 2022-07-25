using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;


namespace BookSystem.Models
{

    public class BookService
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
        /// 新增書本
        /// </summary>
        /// <param name="book"></param>
        /// <returns></returns>
        public int InsertBook(Models.Books book)
        {

            string sql = @"INSERT INTO BOOK_DATA(BOOK_NAME, BOOK_CLASS_ID, BOOK_AUTHOR, BOOK_BOUGHT_DATE, BOOK_PUBLISHER, BOOK_AMOUNT,BOOK_NOTE, 
                            BOOK_STATUS,CREATE_DATE, CREATE_USER, MODIFY_DATE, MODIFY_USER,BOOK_KEEPER)
						   VALUES(@BookName,@BookClassID,@BookAuthor,@BookBoughtDate,@BookPublisher,@BookAmount,@BookNote,@CanBeLend,getDate(),@Admin,getDate(),@Admin,@KeepID)
                           SELECT SCOPE_IDENTITY()";

            int BookID;
            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.Add(new SqlParameter("@BookName", book.BookName));
                cmd.Parameters.Add(new SqlParameter("@BookClassID", book.BookClassID));
                cmd.Parameters.Add(new SqlParameter("@BookAuthor", book.BookAuthor));
                cmd.Parameters.Add(new SqlParameter("@BookBoughtDate", book.BookBoughtDate));
                cmd.Parameters.Add(new SqlParameter("@BookPublisher", book.BookPublisher));
                cmd.Parameters.Add(new SqlParameter("@BookAmount", book.BookAmount));
                cmd.Parameters.Add(new SqlParameter("@BookNote", book.BookNote));
                cmd.Parameters.Add(new SqlParameter("@KeepID", book.KeeperId == null ? string.Empty : book.KeeperId));
                cmd.Parameters.Add(new SqlParameter("@CanBeLend", "A"));
                // 可以借出
                cmd.Parameters.Add(new SqlParameter("@Admin", "Admin"));
                SqlTransaction Tran = conn.BeginTransaction();
                cmd.Transaction = Tran;
                try
                {
                    BookID = Convert.ToInt32(cmd.ExecuteScalar());
                    Tran.Commit();
                }
                catch (Exception)
                {
                    Tran.Rollback();
                    throw;
                }
                finally
                {
                    conn.Close();
                }

            }
            return BookID;
        }


        /// <summary>
        /// Update Book Information
        /// </summary>
        /// <param name="book"></param>
        /// <returns></returns>
        public int UpdateBookInfor(Models.Books book)
        // TODO: lend record need update
        {
            //DataTable dt = new DataTable();
            string sql = @"UPDATE BOOK_DATA
                            SET BOOK_NAME = @BookName
                               ,BOOK_CLASS_ID = @BookClassID
                               ,BOOK_AUTHOR = @BookAuthor
                               ,BOOK_BOUGHT_DATE = @BookDate
                               ,BOOK_PUBLISHER = @BookPublisher
                               ,BOOK_NOTE = @BookNote
                               ,BOOK_STATUS = @BookStatus
                               ,BOOK_KEEPER = @BookKeeper
                            WHERE BOOK_ID = @BookId";
            // 已借出的狀態
            if (book.BookStatus == "B" || book.BookStatus == "C")
            {
                sql += @" 
                        INSERT INTO BOOK_LEND_RECORD
                        (
                            BOOK_ID, KEEPER_ID, LEND_DATE, 
                            CRE_DATE, CRE_USR, MOD_DATE, MOD_USR
                        )
                        VALUES
                        (
                            @BookId, @BookKeeper, GETDATE(),
                            GETDATE(),'Admin', GETDATE(),'Admin'
                        )";
            }

            int result;
            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlTransaction tran = conn.BeginTransaction();
                SqlCommand sqlCommand = new SqlCommand(sql, conn);
                sqlCommand.Parameters.Add(new SqlParameter("@BookId",book.BookID));
                sqlCommand.Parameters.Add(new SqlParameter("@BookName", book.BookName ?? string.Empty));
                sqlCommand.Parameters.Add(new SqlParameter("@BookClassID", book.BookClassID == null ? string.Empty : book.BookClassID));
                sqlCommand.Parameters.Add(new SqlParameter("@BookAuthor", book.BookAuthor == null ? string.Empty : book.BookAuthor));
                sqlCommand.Parameters.Add(new SqlParameter("@BookDate", book.BookBoughtDate == null ? string.Empty : book.BookBoughtDate));
                sqlCommand.Parameters.Add(new SqlParameter("@BookPublisher", book.BookPublisher == null ? string.Empty : book.BookPublisher));
                sqlCommand.Parameters.Add(new SqlParameter("@BookNote", book.BookNote == null ? string.Empty : book.BookNote));
                sqlCommand.Parameters.Add(new SqlParameter("@BookStatus", book.BookStatus == null ? string.Empty : book.BookStatus));
                sqlCommand.Parameters.Add(new SqlParameter("@BookKeeper", book.KeeperId == null ? string.Empty : book.KeeperId));
                sqlCommand.Transaction = tran;
                try
                {
                    result = Convert.ToInt32(sqlCommand.ExecuteNonQuery());
                    tran.Commit();
                }
                catch (Exception)
                {
                    tran.Rollback();
                    throw;
                }
                finally
                {
                    conn.Close();
                }

            }
            return result;



        }


        /// <summary>
        ///  Get Book By Condtioin
        /// </summary>
        /// <param name="arg"></param>
        /// <returns></returns>
        public List<Models.Books> GetBookByCondtioin(Models.BookSearchArg arg)
        {
            DataTable dt = new DataTable();
            string sql = @"
                        SELECT 
	                        bd.BOOK_ID AS BookId, bc.BOOK_CLASS_NAME AS BookClassName, bd.BOOK_NAME AS BookName, 
	                        FORMAT(bd.BOOK_BOUGHT_DATE,'yyyy/MM/dd') AS BookBoughtDate, 
	                        bc1.CODE_NAME AS BookStatus,bc1.CODE_ID AS BookStatusCode, mm.USER_ENAME AS KeeperEName,
                            bd.BOOK_KEEPER AS KeeperId
                        FROM BOOK_DATA AS bd

                        INNER JOIN BOOK_CLASS AS  bc
	                        ON bd.BOOK_CLASS_ID = bc.BOOK_CLASS_ID

                        LEFT JOIN MEMBER_M AS mm
	                        ON bd.BOOK_KEEPER = mm.[USER_ID]
                        INNER JOIN BOOK_CODE AS bc1
	                        ON bd.BOOK_STATUS = bc1.CODE_ID
		                        AND bc1.CODE_TYPE = 'BOOK_STATUS'

                        WHERE
                            (bd.BOOK_ID = @BookId OR @BookId = 0) AND
	                        (bd.BOOK_NAME LIKE ('%' + @BookName + '%') OR @BookName = '') AND
	                        (bd.BOOK_CLASS_ID = @BookClassId OR @BookClassId = '') AND
	                        (bd.BOOK_KEEPER = @KeeperId OR @KeeperId = '') AND
	                        (bd.BOOK_STATUS = @BookStatusCode OR @BookStatusCode = '')
                        ORDER BY 
                            BookBoughtDate DESC";
            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.Add(new SqlParameter("@BookId", arg.BookId == 0 ? 0 : arg.BookId));
                cmd.Parameters.Add(new SqlParameter("@BookName", arg.BookName == null ? string.Empty : arg.BookName));
                cmd.Parameters.Add(new SqlParameter("@BookClassId", arg.BookClassId == null ? string.Empty : arg.BookClassId));
                cmd.Parameters.Add(new SqlParameter("@KeeperId", arg.KeeperId == null ? string.Empty : arg.KeeperId));
                cmd.Parameters.Add(new SqlParameter("@BookStatusCode", arg.BookStatusCode == null ? string.Empty : arg.BookStatusCode));
                SqlDataAdapter sqlAdpater = new SqlDataAdapter(cmd);
                sqlAdpater.Fill(dt);
                conn.Close();

            }


            return this.MapBookDataToList(dt);
        }

        /// <summary>
        /// 刪除 book
        /// </summary>
        /// <param name="bookId"></param>
        public int DeleteBookById(string bookId)
        {
            try
            {
                // 邏輯部分 bool
                string sql = @"DELETE FROM BOOK_DATA 
                                WHERE BOOK_ID = @BookID AND BOOK_STATUS = 'A' ";
                using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.Add(new SqlParameter("@BookID", bookId));
                    SqlTransaction Tran = conn.BeginTransaction();
                    cmd.Transaction = Tran;
                    try
                    {
                        var isSuccess = cmd.ExecuteNonQuery();
                        Tran.Commit();
                        return isSuccess;
                    }
                    catch (Exception)
                    {
                        Tran.Rollback();
                        throw;
                    }
                    finally
                    {
                        conn.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        /// <summary>
        /// 根據書本ID拿資料
        /// </summary>
        /// <param name="bookId"></param>
        /// <returns></returns>
        public Models.Books GetBookByID(int bookId)
        {
            DataTable dt = new DataTable();
            string sql = @"
                        SELECT 
	                       bd.BOOK_ID AS BookId, bc.BOOK_CLASS_ID AS BookClassId, bd.BOOK_NAME AS BookName, 
	                       bd.BOOK_AUTHOR AS BookAuthor, bd.BOOK_PUBLISHER AS BookPublisher, bc1.CODE_ID AS BookStatusCode,
                           bd.BOOK_KEEPER AS KeeperId, bd.BOOK_AMOUNT AS BookAmount, bd.BOOK_NOTE AS BookNote, 
                           FORMAT(bd.BOOK_BOUGHT_DATE,'yyyy-MM-dd') AS BookBoughtDate
                        FROM BOOK_DATA AS bd
	                        INNER JOIN BOOK_CLASS AS bc
		                        ON bd.BOOK_CLASS_ID = bc.BOOK_CLASS_ID
	                        LEFT JOIN MEMBER_M AS mm
		                        ON bd.BOOK_KEEPER = mm.[USER_ID]
	                        INNER JOIN BOOK_CODE AS bc1
		                        ON bd.BOOK_STATUS = bc1.CODE_ID AND bc1.CODE_TYPE = 'BOOK_STATUS'
                        WHERE
                            bd.BOOK_ID = @BookId";

            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.Add(new SqlParameter("@BookId", bookId));
                SqlDataAdapter sqlAdpater = new SqlDataAdapter(cmd);
                sqlAdpater.Fill(dt);
                conn.Close();


            }
            Models.Books result = new Books();
            if (dt.Rows.Count != 0)
            {


                result.BookID = (int)dt.Rows[0]["BookId"];
                result.BookClassID = dt.Rows[0]["BookClassId"].ToString();
                result.BookName = dt.Rows[0]["BookName"].ToString();
                result.BookAuthor = dt.Rows[0]["BookAuthor"].ToString();
                result.BookPublisher = dt.Rows[0]["BookPublisher"].ToString();
                result.BookStatus = dt.Rows[0]["BookStatusCode"].ToString();
                result.KeeperId = dt.Rows[0]["KeeperId"].ToString();
                result.BookNote = dt.Rows[0]["BookNote"].ToString();
                result.BookBoughtDate = dt.Rows[0]["BookBoughtDate"].ToString();
                result.BookAmount = dt.Rows[0]["BookAmount"].ToString();

            }

            return result;
        }



        /// <summary>
        /// 根據書本ID拿借閱資料
        /// </summary>
        /// <param name="BookId"></param>
        /// <returns></returns>
        public List<BookLend> GetBookLendRecordByBookID(int bookId)
        {
            DataTable dt = new DataTable();
            try
            {
                // join
                string sql = @"SELECT
                                    blr.BOOK_ID as BookId
	                               ,FORMAT(blr.LEND_DATE, 'yyyy/MM/dd') AS LendDate
                                   ,mm.USER_ID AS UserId
                                   ,mm.USER_ENAME AS UserEName
                                   ,mm.USER_CNAME AS UserCName
                                FROM BOOK_LEND_RECORD AS blr
                                LEFT JOIN MEMBER_M AS mm
	                                ON blr.KEEPER_ID = mm.USER_ID
                                WHERE blr.BOOK_ID = @BookId
                                ORDER BY LendDate
                                ";
                using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.Add(new SqlParameter("@BookId", bookId));
                    SqlDataAdapter sqlAdpater = new SqlDataAdapter(cmd);
                    sqlAdpater.Fill(dt);
                    conn.Close();

                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            List<Models.BookLend> result = new List<Models.BookLend>();
            foreach (DataRow row in dt.Rows)
            {
                result.Add(new Models.BookLend()
                {
                    BookID = row["BookId"].ToString(),
                    LendDate = row["LendDate"].ToString(),
                    KeeperId = row["UserId"].ToString(),
                    UserEName = row["UserEName"].ToString(),
                    UserCName = row["UserCName"].ToString()
                });
            }
            return result;

        }


        /// <summary>
        /// Map Book Data To List
        /// </summary>
        /// <param name="dt"></param>
        /// <returns></returns>
        private List<Models.Books> MapBookDataToList(DataTable dt)
        {
            List<Models.Books> result = new List<Books>();
            foreach (DataRow row in dt.Rows)
            {
                result.Add(new Books()
                {

                    BookID = (int)row["BookId"],
                    BookClassName = row["BookClassName"].ToString(),
                    BookName = row["BookName"].ToString(),
                    BookBoughtDate = row["BookBoughtDate"].ToString(),
                    BookStatus = row["BookStatus"].ToString(),
                    CodeID = row["BookStatusCode"].ToString(),
                    UserName = row["KeeperEName"].ToString(),
                    KeeperId = row["KeeperId"].ToString()

                });
            }
            return result;
        }

    }
}