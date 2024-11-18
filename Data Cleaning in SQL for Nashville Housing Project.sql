/*
	Data Cleaning in SQL Quaries
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
-----------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add Sale_Date Date;

UPDATE dbo.NashvilleHousing
SET Sale_Date = CONVERT(Date, SaleDate);

SELECT Sale_Date
FROM PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

-- Popular Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID;

	-- USE 'self join' if the ParcelID duplicates, make the PropertyAddresss is not NULL

	-- ISNULL() returns a specified value if the expression is null

	SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM PortfolioProject.dbo.NashvilleHousing a
	JOIN PortfolioProject.dbo.NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.UniqueID <> b.UniqueID -- <> = Not Equal
	WHERE a.PropertyAddress is null

	
	UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM PortfolioProject.dbo.NashvilleHousing a
	JOIN PortfolioProject.dbo.NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.UniqueID <> b.UniqueID -- <> = Not Equal
	WHERE a.PropertyAddress is null


	-- Check if there is any null for PropertyAddress
	SELECT *
	FROM PortfolioProject.dbo.NashvilleHousing
	WHERE PropertyAddress is null


------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, city, state)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID


	-- Try to test/split before changing in table
	-- CharIndex() returns index number of searching char

	SELECT PropertyAddress,
	SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
	FROM PortfolioProject.dbo.NashvilleHousing
	ORDER BY ParcelID


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


--To split the OwnerAddress, we don't use 'SUBSTRING' and use 'PARSENAME'
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

-- Split the OwnerAddress using 'PARSENAME' (test_query)
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as O_Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'SoldAsVacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END	
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID


UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END	
FROM PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
					ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
-- If you really want to remove duplicates, replace 'DELETE' instead of 'SELECT *'
SELECT *
FROM RowNumCTE
WHERE row_num > 1


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress
